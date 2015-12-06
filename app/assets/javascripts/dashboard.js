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
        $.each( data.recommendation, function( i, item ) {
          var row = "<tr>";
          row +="<td class=\"text-center\">"+item.rank+"</td>";
          row +="<td class=\"text-center\"><span class=\"label label-primary\">"+item.mykad+"</span></td>";
          row +="<td>"+item.name+"</td>";
          row +="<td class=\"text-center\">"+item.pngk+"</td>";
          row +="<td><code>STPM: PA-3.5, PP-3.75</code><code>SPM: BM-A, BI-C</code></td>";
          row +="<td class=\"text-center\"><span class=\"label label-default\">"+item.choicerank+"</span></td>";
          row +="<td class=\"text-center\">"+item.distance+"</td>";
          row +="</tr>";
          $('#table_result').append(row);
        });
      });
  });
});