function init_top_button(){
  // 先頭に戻るボタン機能
  $('#top_button').hide();
  // なぜか適用されない
  $('#top_button').on('click', function(){
    $(window).scrollTop(0);
    $(window).animate({scrollTop: 0}, 'fast');
  });
  // スクロール時
  $(window).scroll(function(){
    // 先頭かどうか
    if($(window).scrollTop() > 0)
      $('#top_button').fadeIn();
    else
      $('#top_button').fadeOut();
  });
}

moment.locale('ja');
init_top_button();
