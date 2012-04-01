
function wopen(obj, w, h) {
        if(!w) { w = 800; }
        if(!h) { h = 600; }
        winoptions="height="+h+",width="+w+",,"+
                ",menubar=no,resizable=yes,scrollbars=yes,status=no,titlebar=no,toolbar=no";
        win=window.open("","info",winoptions);
        win.location.href=obj.href;
        if (parseInt(navigator.appVersion) >= 4)  { win.window.focus(); }
        return false;
}


function wclose() {
    var ua = navigator.userAgent.toLowerCase();
    if((/msie/.test(ua)) && !(/opera/.test(ua)) && (/win/.test(ua))) {
		window.opener='X';
	}
	window.close();
	return false;
}



function preventEnterSubmit() {

    var inputs = document.getElementsByTagName('input');
    for (var i=0; i<inputs.length; i++) {
	
		if(inputs[i].type != "text" && inputs[i].type != "password") continue;
		
        if(inputs[i].onkeypress) continue;
        
        inputs[i].onkeypress = function (e) {
			var keycode;
			if (window.event) keycode = window.event.keyCode;
            else if (e) keycode = e.which;
            else return true;
            
            if (keycode == 13) {
               return false;
            } else {
               return true;
			}
        }
    }
}


function addOnLoad(initFunction) {
	if ( typeof window.addEventListener != "undefined" ) {
  	  window.addEventListener( "load", initFunction, false );
	} else if ( typeof window.attachEvent != "undefined" ) {
  	  window.attachEvent( "onload", initFunction );
	} else {
 		if ( window.onload != null ) {
			var oldOnload = window.onload;
			window.onload = function ( e ) {
    	        oldOnload( e );
     	        initFunction();
    		};
		} else {
        	window.onload = initFunction;
        }
	}
}



function prepareForBack() {
	formValidate = function(f,g) {
		return true;
	}
	return true;
}




function formValidate(form, group) {
	
	if (!confirmMessage(form)) return false;

    if(! (notNull(requiredFields) && notNull(requiredFields[group]) && notNull(errorMessages) && notNull(errorMessages[group]) && notNull(form))) return true;

	var errors = checkRequiredFields(group);
	
	if (errors.length == 0) return submitOnlyOnce(form);
	
	clearErrors(requiredFields[group]);
	try {
		if (notNull(serverValidationFields)) {
			clearErrors(serverValidationFields);
		}	
	} catch (err) {}
	markErrorFields(errors);
	setErrorMessages(errors, group);
	return false;
}

function checkRequiredFields(group) {

	var errors = new Array();
    
	if(! (notNull(requiredFields) && notNull(requiredFields[group]) && notNull(errorMessages) && notNull(errorMessages[group]))) {
		return errors;
	}

	for(var i = 0; i < requiredFields[group].length; ++i) {
		el = document.getElementById(requiredFields[group][i]);	
		if(! validateElement(el)) {
			errors.push(requiredFields[group][i]);
		}
		
		if(notNull(validationFunctions) && notNull(validationFunctions[group]) && notNull(validationFunctions[group][requiredFields[group][i]])) {
			if(! validationFunctions[group][requiredFields[group][i]](el)) {
				errors.push(requiredFields[group][i]);
			}
		}
	}
	return errors;
}

function validateElement(el) {
    if (!notNull(el)) return true;
    
    if (el.type == "text" || el.type == "hidden" || el.type == "password") {
      if (trim(el.value) == "") {
        return false;
      }
    } else if (el.type == "radio") {
      var itemchecked = false;
      var elems = document.getElementsByTagName("input");
      for(var j = 0; j < elems.length; ++j) {
        if(elems[j].type == "radio" && elems[j].name == el.name) {
          if(elems[j].checked && trim(elems[j].value) != "") {
            itemchecked = true;
		    break;
          }
        }
      }
      if(!itemchecked) { 
        return false;
      }
    } else if (el.type == "checkbox") {
      var itemchecked = false;
      var elems = document.getElementsByTagName("input");
      for(var j = 0; j < elems.length; ++j) {
        if(elems[j].type == "checkbox" && elems[j].name == el.name) {
          if(elems[j].checked) {
            itemchecked = true;
        	break;
          }
        }
      }
      if(!itemchecked) { 
        return false;
      }
    } else if (el.type == "textarea") {
      if (trim(el.value) == "") {
        return false;
      }
    } else if (el.type == "select-one") {
      if (el.selectedIndex == 0) {
        return false;
      }
    } else if (el.type=="select-multiple") {
      var optionselected = false;
      for(var j=0;j<el.options.length; ++j) {
        if (el.options[j].selected) {
      	  optionselected = true;
      	  break;
      	}
      }
      if (!optionselected) {
        return false;
      }
    }
    return true;
}


function markErrorFields(errors) {
	if(errors.length == 0) return;
	for(var i = 0; i < errors.length; ++i) {
		el = document.getElementById(errors[i]);
		if(! notNull(el)) continue;
		if(el.type == "hidden") continue;
		if (el.parentNode.nodeName == "DIV") {
			el.parentNode.className = "errorDiv";
		}
		el.className = "errorField";
	}
	
}

function setOkMessages(messages) {
	if ( notNull(document.getElementById("okFrameMessages"))) {
		var messageHTML = "";
		for(var i = 0; i < messages.length; ++i) {
			messageHTML += messages[i];
			messageHTML += "<br />";
		}	
		document.getElementById("okFrameMessages").innerHTML = "<span class='green'>" + messageHTML + "</span>";
		showElement("okFrame");
		showElement("okFrameMessages");
	}
}

function setErrorMessages(errors,group) {
	if ( notNull(document.getElementById("errorFrameValidationErrors"))) {
		var messageHTML = "";
		if(errors.length > 3) {
			messageHTML = errorMessages[group]["generic"];
		} else {
			for(var i = 0; i < errors.length; ++i) {				
				messageHTML += errorMessages[group][errors[i]];
				messageHTML += "<br />";
			}	
		}
		document.getElementById("errorFrameValidationErrors").innerHTML = "<span class='red'>" + messageHTML + "</span>";
		showElement("errorFrame");
		showElement("errorFrameValidationErrors");
	}
	hideElement("okFrame");
}


function clearErrors(fields, dontHideErrorFrame) {
	for(var i = 0; i < fields.length; ++i) {
		obj = document.getElementById(fields[i]);
		
		if(! notNull(obj)) continue; 
		
		if (obj.parentNode.nodeName == "DIV") {
			obj.parentNode.className = "fieldDiv";
		}
		obj.className = "inputField";
	}
	if(! dontHideErrorFrame) {
		hideElement("errorFrameValidationErrors");
		if(! notNull(document.getElementById("errorFrameCustomFieldErrors"))) {
			hideElement("errorFrame");
		}
	}
	hideElement("okFrame");
}

function showElement(elId) {
    if (notNull(document.getElementById(elId))) {
            document.getElementById(elId).style.display = 'block';
    }
    return false;
}
function hideElement(elId) {
    if (notNull(document.getElementById(elId))) {
            document.getElementById(elId).style.display = 'none';
    }
    return false;
}
function toggleElement(elId) {
    if (notNull(document.getElementById(elId))) {
    		if(document.getElementById(elId).style.display == 'block') {
            	document.getElementById(elId).style.display = 'none';
            } else {
            	document.getElementById(elId).style.display = 'block';
            }
    }
    return false;
}

function notNull(objToTest) {
  if (null == objToTest) {
     return false;
  }
  if ("undefined" == typeof(objToTest) ) {
     return false;
  }
  return true;
}


function trim(s){ return rtrim(ltrim(s)); }

function ltrim(s){
        var w = " \n\t\f";
        // remove all beginning white space
        while( w.indexOf(s.charAt(0)) != -1 && s.length != 0 ) s = s.substring(1);
        return s;
}

function rtrim(s){
        var w = " \n\t\f";
        // remove all ending white space
        while( w.indexOf(s.charAt(s.length-1)) != -1 && s.length != 0 ) s = s.substring(0, s.length-1);
        return s;
} 

function digitsOnly(s){
	var w = "0123456789";
	var r = "";
	for(var i=0; i<s.length; i++) {
		if(w.indexOf(s.charAt(i)) != -1) {
			r += s.charAt(i);
		}
	}
	return r;
}

function removeLeadingZeros(s) {
	while( s.charAt(0) == "0" && s.length != 0 ) s = s.substring(1);
	return s;
}

function submitOnlyOnce(f) {

		if(typeof(maySubmitOnlyOnce) == "undefined") {
		  return true;
		} else if (maySubmitOnlyOnce == false){
		  return true;
		}
		
        for (i=1; i<f.elements.length; i++) {
          if (f.elements[i].type == 'submit' || f.elements[i].type == 'button') {
                  f.elements[i].disabled = true;
          }
        }
        f.submit();
        submitOnlyOnce = function (f) {
          return false;
        };
        var errors = new Array();
        errors.push("submitonce");
        setErrorMessages(errors,"default");
        hideElement("errorFrameCustomFieldErrors");
        
        return false;
}

function confirmMessage(f) {
	
	if(typeof(confirmOnSubmit) == "undefined") {
		return true;
	}
	if (confirm(errorMessages["confirm"])) {
		return true;
	} 
	return false;
}

//  vX library (Ajax, Extend, GetElement, Animation)
var _=_?_:{}
_.X=function(u,f,d,x){x=new(window.ActiveXObject?ActiveXObject:XMLHttpRequest)('Microsoft.XMLHTTP');x.open(d?'POST':'GET',u,1);d?x.setRequestHeader('Content-type','application/x-www-form-urlencoded'):0;x.onreadystatechange=function(){x.readyState>3&&f?f(x.responseText,x):0};x.send(d)}
_.E=function(e,t,f,r){if(e.attachEvent?(r?e.detachEvent('on'+t,e[t+f]):!0):(r?e.removeEventListener(t,f,!1):e.addEventListener(t,f,!1))){e['e'+t+f]=f;e[t+f]=function(){e['e'+t+f](window.event)};e.attachEvent('on'+t,e[t+f])}}
_.G=function(e){return e.style?e:document.getElementById(e)}
_.A=function(v,n,c,u,y){if(u===undefined){var u=new Object();u.value=0};u.value?0:u.value=0;return y.value=setInterval(function(){c(u.value/v);++u.value>v?clearInterval(y.value):0},n)}
_.F=function(d,h,f,i){d=d=='in';_.A(f?f:15,i?i:50,function(a){a=(d?0:1)+(d?1:-1)*a;h.style.opacity=a;h.style.filter='alpha(opacity='+100*a+')'})}
_.S=function(d,h,f,i,w,t,c){d=d=='in';_.A(f?f:15,i?i:50,function(a){a=(d?0:1)+(d?1:-1)*a;h.style.width=parseInt(a*w)+"px";},c,t);}
_.Q=function(f){var o=new Object();var r=new Array();
	for(var i=0;i < f.elements.length;i++){
		try {l=f.elements[i];n=l.name;
			if(n=='')continue;
			switch(l.type.split('-')[0]){
				case "select":
					for(var s=0;s < l.options.length;s++){
						if(l.options[s].selected){
							if(typeof(o[n])=='undefined')o[n]=new Array();
							o[n][o[n].length]=encodeURIComponent(l.options[s].value);}}break;
				case "radio":
					if(l.checked){
						if(typeof(o[n])=='undefined')o[n]=new Array();
						o[n][o[n].length]=encodeURIComponent(l.value);}break;
				case "checkbox":
					if(l.checked){
						if(typeof(o[n])=='undefined')o[n] = new Array();
						o[n][o[n].length]=encodeURIComponent(l.value);}break;
				case "submit":
					break;
				default:
					if(typeof(o[n])=='undefined')o[n] = new Array();
					o[n][o[n].length]=encodeURIComponent(l.value);break;
			}
		}catch(e){}
	} for(x in o){r[r.length]=x+'='+o[x].join(',');}return r.join('&'); 
}