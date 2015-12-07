class ApiController < ApplicationController
  
  def search_program
    q = params[:q]
    rs = Hash.new
    
    tmp = Program.where('programlevel_code = ? AND nameeng LIKE ?','I','%'+q.upcase+'%')
    
    rs[:count] = tmp.count
    rs[:items] = tmp
    
    render :json => rs
  end
  
  
  def topsis
    tstart = Time.now
    log = "<samp>Running TOPSIS for program <span class=\"label label-primary\">"+params[:upucode]+"</span></samp><br/>"
    log += "<samp>Start program at #{tstart.strftime("%d/%m/%Y at %T%p")}</samp><br />"
 
    #@url_params = params.to_param.sub("action=rekomendasi&controller=webhosts&", "")
    
    #1) get all qualified candidate from selection list. (1-12th choice)
    @rs = Jayauitmstpm.getselection(params[:upucode])
    log += "<br\><samp>1) Select candidate:  <kbd>#{@rs.count}</kbd> out of #{Jayauitmstpm.count} selected for alternative</samp><br />"
    
    #2) initialize preferences from user's form
    @ar_pref = Array.new
    @preferences = initialize_preferences
    log += "<samp>2) Initialize preferences: <kbd>#{@preferences.count} Pref</kbd> selected.</samp><br />"
    
    #3) initialize decision matrix (DM)
    dm = initialize_decision_matrix
    log += "<samp>3) Initialize decision matrix: <kbd>#{dm.count} alternative x #{@preferences.count} pref</kbd></samp><br />"

    #4) Normalize DM
    dm = normalize_decision_matrix(dm)
    log += "<samp>4) Normalize decision matrix</samp><br />"

    dm = weighted_decision_matrix(dm, @preferences)
    log += "<samp>5) Weighted decision matrix</samp><br />"
    
    ideal_positive = find_ideal_solution(dm)
    log += "<samp>6) Find ideal positive:</samp><br/><code>"+ideal_positive.to_a.to_s+"</code><br />"
    ideal_negative = find_ideal_solution(dm, false)
    log += "<samp>7) Find ideal negative:</samp><br/><code>"+ideal_negative.to_a.to_s+"</code><br />"
  
    recommendation = calculate_distance(dm, ideal_positive, ideal_negative)
         
    #initialize thead for result table
    thead = %w[rank mykad name pngk ]                #field wajib
    thead.push('koko') if !@preferences['koko'].nil?
    thead.push('pendapatan') if !@preferences['pendapatan'].nil?
    thead += %w[exam choicerank distance]           #field wajib
    
    count = 0;
    recommendation = recommendation.map do |rx|
      r = Jayauitmstpm.find(rx.first[1].to_i)
      {
        id: r.id,
        rank: count+=1,
        distance: rx[:mostmatchvalue].round(8),
        katag: r.KATAG,
        choicerank: r.choice_rank(params[:upucode]),
        name: r.NAMA,
        mykad: r.NOKP,
        muet: r.TMUET,
        pngk: r.PURATAPNGK,
        koko: r.MARKOKOKPM,
        exam: r.examresult,
        pendapatan: r.pendapatankeluarga_detail
      }
    end
   
    #calculate elapsed time to run the algorithm
    tstop = Time.now
    elapsed_seconds = ((tstop - tstart) * 24 * 60).to_i
    log += "<br\><samp>End program at #{tstop.strftime("%d/%m/%Y at %T%p")} in <kbd>#{elapsed_seconds} milisecond</kbd></samp>"
    
    infotable = "<p><code>#{recommendation.count}</code> Student suggested based on your preferences.</p>"

    #render to json format
    render :json => { 
              :params => params, 
              :preferences => @preferences,
              :dm => dm,
              :ideal_positif => ideal_positive,
              :ideal_negative => ideal_negative,
              :log => log, 
              :info => infotable,
              :thead => thead,
              :recommendation =>recommendation
            }
  end
  
  private
    def mappingdb(key)
      return case key
        when 'pngk'
          'PURATAPNGK'
        when 'koko'
          'MARKOKOKPM'
        when 'pendapatan'
          "PDAPATK"
        else
          nil
      end
    end
    # Baca range dari pengaturan
    def range(key)
      r = pengaturan(key).split("-")
      bawah = r[0].to_i
      atas = r[1].to_i
      r = bawah..atas
    end

    # Using min-max normalization to the range of [1.0, 5.0] 
    def minmax(v, range, new_range=1.0..5.0)
      v = v.to_f
      min = range.first.to_f
      max = range.last.to_f
      min = (min == max)? 0 : min
      new_min = new_range.first.to_f
      new_max = new_range.last.to_f
      new_v = ((v-min)/(max-min))*(new_max-new_min)+new_min
      new_v.round(2)
    end

    def initialize_preferences
      p = Hash.new
      
      params[:preferences].each do |pref| 
        tmp = pref.split("|")
        p[tmp[0]] = tmp[1].to_f.to_s
        @ar_pref.push tmp[0]
      end
      return p
    end

    def initialize_decision_matrix
      ndm = []
      min = {}
      max = {}
      
      @ar_pref.each do |p|
        min[p] = @rs.minimum(mappingdb(p))
        max[p] = @rs.maximum(mappingdb(p))
      end

      @rs.each do |w|
        alt = {}
        alt[:id]                = w.id
        @ar_pref.each do |p|
          alt[p]                = minmax(w[mappingdb(p)],min[p]..max[p])
        end
        ndm << alt
      end
      return ndm
    end

    def normalize_decision_matrix(dm)
      ndm = []
      total = Hash.new
      @ar_pref.each do |p|
        total[p] = 0
      end
      dm.each do |alt|
        @ar_pref.each do |p|
          total[p]   += alt[p]
        end
      end
      
      total.each {|key, value| total[key] = Math.sqrt(value)}
      
      dm.each do |alt|
        @ar_pref.each do |p|
          alt[p]   /= total[p]
        end
        ndm << alt
      end
      return ndm
    end

    # Menyusun matriks keputusan ternormalisasi terbobot
    def weighted_decision_matrix(dm, pref)
      wdm = []
      dm.each do |alt|
        @ar_pref.each do |p|
          alt[p]   *= pref[p].to_f
        end
        wdm << alt
      end
      return wdm
    end

    # ideal positif = benefit criteria
    # ideal negatif = cost criteria
    def find_ideal_solution(dm, positif=true)
      i = {} #ideal
      skip = %w[id]
      dm.each do |alt|
        alt.each do |key, value|
          unless skip.include? key.to_s
            i[key] ||= value;
            if positif
              i[key] = (i[key] > value)? i[key] : value
            else
              i[key] = (i[key] < value)? i[key] : value
            end
          end
        end
      end
      return i
    end

    # Find relative distance for each alternative to ideal solution:
    # 1. Calculate distance from ideal positif
    # 2. Calculate distance from ideal negative
    # 3. Calculate proximity of relative distance from ideal +ve (pref value), closer are better
    def calculate_distance(dm, ideal_positif, ideal_negatif)
      dm.each {|alt| separasi = 0; ideal_positif.each{|key, value| separasi += (alt[key] - value)**2 }; alt[:separation_benefit] = separasi }
      dm.each {|alt| separasi = 0; ideal_negatif.each{|key, value| separasi += (alt[key] - value)**2 }; alt[:separation_cost] = separasi }
      dm.each {|alt| alt[:mostmatchvalue] = alt[:separation_cost]/(alt[:separation_cost]+alt[:separation_benefit])}
      dm.sort_by! {|alt| alt[:mostmatchvalue] }
      return dm.reverse!
    end
end
