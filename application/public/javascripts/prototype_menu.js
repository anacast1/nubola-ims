function hideMenus(){
  $('menu1').setStyle({'display':'none'});
}

function toggleMenu(menuid){
  if ($(menuid).style.display && $(menuid).style.display != 'block'){
    var p = $(menuid).parentNode;
    $(menuid).setStyle({'left':p.offsetLeft});
    $(menuid).setStyle({'display':'block'});
  }else{
    $(menuid).setStyle({'display':'none'});
  }
}
