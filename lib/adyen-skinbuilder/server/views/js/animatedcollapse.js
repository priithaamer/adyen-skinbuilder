//Animated Collapsible DIV- Author: Dynamic Drive (http://www.dynamicdrive.com)
//Last updated Aug 1st, 07'. Fixed bug with "block" parameter not working when persist is enabled
//Updated June 27th, 07'. Added ability for a DIV to be initially expanded.


function animatedcollapse(divId, animatetime, persistexpand, initstate, animate){
	this.animate=animate
	this.divId=divId
	this.divObj=document.getElementById(divId)
	this.divObj.style.overflow="hidden"
	this.timelength=animatetime
	this.initstate=(typeof initstate!="undefined" && initstate=="block")? "block" : "contract"
	this.isExpanded="no";
	this.contentheight=parseInt(this.divObj.style.height)
	var thisobj=this
	if (isNaN(this.contentheight)){ //if no CSS "height" attribute explicitly defined, get DIV's height on window.load
		animatedcollapse.dotask(window, function(){thisobj._getheight(persistexpand)}, "load")
		if (!persistexpand && this.initstate=="contract" || persistexpand && this.isExpanded!="yes" && this.isExpanded!="") //Hide DIV (unless div should be expanded by default, OR persistence is enabled and this DIV should be expanded)
			this.divObj.style.visibility="hidden" //hide content (versus collapse) until we can get its height
	}
	else if (!persistexpand && this.initstate=="contract" || persistexpand && this.isExpanded!="yes" && this.isExpanded!="") //Hide DIV (unless div should be expanded by default, OR persistence is enabled and this DIV should be expanded)
		this.divObj.style.height=0 //just collapse content if CSS "height" attribute available
	if (persistexpand){
		animatedcollapse.dotask(window, function(){
		}, "unload")
	}
}

animatedcollapse.prototype._getheight=function(persistexpand){
	this.contentheight=this.divObj.offsetHeight
	if (!persistexpand && this.initstate=="contract" || persistexpand && this.isExpanded!="yes"){ //Hide DIV (unless div should be expanded by default, OR persistence is enabled and this DIV should be expanded)
		this.divObj.style.height=0 //collapse content
		this.divObj.style.visibility="visible"
	}
	else //else if persistence is enabled AND this content should be expanded, define its CSS height value so slideup() has something to work with
		this.divObj.style.height=this.contentheight+"px"
}


animatedcollapse.prototype._slideengine=function(direction, offset){
	var elapsed=new Date().getTime()-this.startTime //get time animation has run
	var thisobj=this
	if (elapsed<this.timelength && this.animate == true){ //if time run is less than specified length
		var distancepercent=(direction=="down")? animatedcollapse.curveincrement(elapsed/this.timelength) : 1-animatedcollapse.curveincrement(elapsed/this.timelength)
		this.divObj.style.height=(offset+(distancepercent * (this.contentheight-offset))) +"px"
		this.runtimer=setTimeout(function(){thisobj._slideengine(direction,offset)}, 10)
	}
	else{ //if animation finished
		this.divObj.style.height=(direction=="down")? this.contentheight+"px" : 0
		this.isExpanded=(direction=="down")? "yes" : "no" //remember whether content is expanded or not
		this.runtimer=null
	}
}


animatedcollapse.prototype.slidedown=function(){
	if (typeof this.runtimer=="undefined" || this.runtimer==null){ //if animation isn't already running or has stopped running
		if (isNaN(this.contentheight)) {//if content height not available yet (until window.onload)
			//alert("Please wait until document has fully loaded then click again")
		} else if (parseInt(this.divObj.style.height)==0){ //if content is collapsed
			this.startTime=new Date().getTime() //Set animation start time
			this._slideengine("down",0)
		}
	}
}

animatedcollapse.prototype.forceslidedown=function(offset){
	if (typeof this.runtimer=="undefined" || this.runtimer==null){ //if animation isn't already running or has stopped running
		if (isNaN(this.contentheight)) {//if content height not available yet (until window.onload)
			//alert("Please wait until document has fully loaded then click again")
		} else { //if content is collapsed
			this.startTime=new Date().getTime() //Set animation start time
			this._slideengine("down",offset)
		}
	}
}

animatedcollapse.prototype.slideup=function(){
	if (typeof this.runtimer=="undefined" || this.runtimer==null){ //if animation isn't already running or has stopped running
		if (isNaN(this.contentheight))  {//if content height not available yet (until window.onload)
			//alert("Please wait until document has fully loaded then click again")		
		} else if (parseInt(this.divObj.style.height)==this.contentheight){ //if content is expanded
			this.startTime=new Date().getTime()
			this._slideengine("up",0)
		}
	}
}

animatedcollapse.prototype.slideit=function(){
	if (isNaN(this.contentheight)) { //if content height not available yet (until window.onload)
		//alert("Please wait until document has fully loaded then click again")
	} else if (parseInt(this.divObj.style.height)==0) {
		this.slidedown()
	} else if (parseInt(this.divObj.style.height)==this.contentheight) {
		this.slideup()
	}
}

// -------------------------------------------------------------------
// A few utility functions below:
// -------------------------------------------------------------------

animatedcollapse.curveincrement=function(percent){
	return (1-Math.cos(percent*Math.PI)) / 2 //return cos curve based value from a percentage input
}


animatedcollapse.dotask=function(target, functionref, tasktype){ //assign a function to execute to an event handler (ie: onunload)
	var tasktype=(window.addEventListener)? tasktype : "on"+tasktype
	if (target.addEventListener)
		target.addEventListener(tasktype, functionref, false)
	else if (target.attachEvent)
		target.attachEvent(tasktype, functionref)
}
