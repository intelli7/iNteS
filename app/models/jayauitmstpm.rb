class Jayauitmstpm < ActiveRecord::Base

  def self.getselection(upucode)
    where("
      (PIL1=? AND LAY1='') OR 
      (PIL2=? AND LAY2='') OR 
      (PIL3=? AND LAY3='') OR 
      (PIL4=? AND LAY4='') OR 
      (PIL5=? AND LAY5='') OR 
      (PIL6=? AND LAY6='') OR 
      (PIL7=? AND LAY7='') OR 
      (PIL8=? AND LAY8='') OR 
      (PIL9=? AND LAY9='') OR 
      (PIL10=? AND LAY10='') OR 
      (PIL11=? AND LAY11='') OR 
      (PIL12=? AND LAY12='')
      ",
      upucode,
      upucode,
      upucode,
      upucode,
      upucode,
      upucode,
      upucode,
      upucode,
      upucode,
      upucode,
      upucode,
      upucode,
      
    )
    
  end
  
  def ajax_result
    
  end
  
  def choice_rank(upucode)
    return 1 if(self.PIL1 == upucode && self.LAY1 == '')
    return 2 if(self.PIL2 == upucode && self.LAY2 == '')
    return 3 if self.PIL3 == upucode && self.LAY3 == ''
    return 4 if self.PIL4 == upucode && self.LAY4 == ''
    return 5 if self.PIL5 == upucode && self.LAY5 == ''
    return 6 if self.PIL6 == upucode && self.LAY6 == ''
    return 7 if self.PIL7 == upucode && self.LAY7 == ''
    return 8 if self.PIL8 == upucode && self.LAY8 == ''
    return 9 if self.PIL9 == upucode && self.LAY9 == ''
    return 10 if self.PIL10 == upucode && self.LAY10 == ''
    return 11 if self.PIL11 == upucode && self.LAY11 == ''
    return 12 if self.PIL12 == upucode && self.LAY12 == ''
    
    return 0
  end
  
  def examresult
    return "Not Available"
  end
  
  def pendapatankeluarga
    return 10-self.PDAPATK.to_i
  end
  
  def pendapatankeluarga_detail
    return case(self.PDAPATK.to_i)
      when 10
        "TIADA PENDAPATAN"
      when 5
        "RM3001-RM4000"
      when 9
        "RM1-RM500"
      when 4
        "RM4001-RM5000"
      when 8
        "RM501-RM1000"
      when 3
        "RM5001-RM7500"
      when 7
        "RM1001-RM2000"
      when 2
        "RM7501-RM10000"
      when 6
        "RM2001-RM3000"
      when 1
        "RM10001 DAN KE ATAS"
      else
        "NIL"
    end
    return 10-self.PDAPATK.to_i
  end
end
