$(document).ready(function() {
  $('select').select2({ width: 'resolve' });
  $('#consolelog').scrollspy({ target: '#consolelog' })

  function get_pref(){
    var pref = []; var count=0;
    if($('#cb_pngk').is(':checked')){
      pref[count++] = 'pngk|'+$('#w_pngk').val();
    }
    if($('#cb_koko').is(':checked')){
      pref[count++] = 'koko|'+$('#w_koko').val();
    }
    if($('#cb_pendapatan').is(':checked')){
      pref[count++] = 'pendapatan|'+$('#w_pendapatan').val();
    }
    if($('#cb_location').is(':checked')){
      pref[count++] = 'location|'+$('#w_location').val();
    }
    
    return pref;
  }
  $('#btn_suggest').click(function(){
    var upucode = $('.programlistselect').val();
    var pref = '';
    $.getJSON( '/get_recommendation/'+upucode,{
        preferences: get_pref()
      }).success(function( data ) {
        //console.dir(data);
        $('#table_result').html(''); $('#log_console').html('');$('#table_result_info').html('');
      
        $('#log_console').html(data.log);
        $('#table_result_info').html(data.info);
        
      
        thead = "<tr>"
        $.each( data.thead, function( i, item ) {
          thead += "<th class=\"text-center\">"+item.toUpperCase()+"</th>"
        });
        thead += "</tr>"
        $('#table_result_header').html(thead);
      
      
        $.each( data.recommendation, function( i, item ) {
          var row = "<tr>";
          $.each( data.thead, function( j, th ) {
            row += "<td class=\"text-center\">"+item[th]+"</td>"
          });
          
          row +="</tr>";
          $('#table_result').append(row);
        });
      });
  });
});