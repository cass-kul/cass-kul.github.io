
function SwiperBox(fields) {
    var self = this;

    this.HTMLElement = document.createElement("div");

    this.HTMLElement.style.width = "100%";
	
    this.HTMLElement.style.overflow = "hidden";
    this.HTMLElement.style.position = "relative";
    this.HTMLElement.style.direction = "ltr";
	

	
    var container = document.createElement("div");

    container.style.position = "absolute";
    container.style.left = "0px";
    container.style.top = "0px";
    container.style.width = "100%";
    container.style.height = "100%";
    container.style.whiteSpace = "nowrap";

    var ratio = document.createElement("img");
	//this is 1X1 png image so you can change it to any ratio you want
    ratio.src = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAMSURBVBhXY/j//z8ABf4C/qc1gYQAAAAASUVORK5CYII=';
     if (typeof fields.ratio !== 'undefined') {
		 ratio.src = fields.ratio;
	 }
	ratio.style.width = "100%";
    ratio.style.visibility = "hidden";

    this.HTMLElement.appendChild(ratio);
    this.HTMLElement.appendChild(container);

    var elem_conts = [];

    for (var i = 0; i < fields.items.length; i++) {

        var itm = document.createElement("div");
        itm.style.width = "100%";
        itm.style.height = "100%";
        itm.style.display = "inline-block";
        itm.style.position = "relative";

        var itmcont = document.createElement("div");
        itmcont.style.position = "absolute";
        itmcont.style.left = "0px";
        itmcont.style.top = "0px";
        itmcont.style.width = "100%";
        itmcont.style.height = "100%";
		
		if (typeof fields.items[i] == 'object') {
			itmcont.appendChild(fields.items[i])
		} else {
			var titm = document.createElement("div");
			titm.innerHTML = fields.items[i];
			titm.style.width = "inherit";
			titm.style.height = "inherit";
		    itmcont.appendChild(titm);
			fields.items[i] = titm;
		}

        itm.appendChild(itmcont);

        elem_conts.push(itm)
        container.appendChild(itm);

    }

    this.start = 0;
    this.mainpos = 0;
    this.stpx = 0;
    this.numx = 0;
    this.movied = true;
    this.mousedown = false;

    this.swipStart = function(e) {
        e.preventDefault();
        self.mousedown = true;
        if (typeof e.changedTouches !== 'undefined') {
            self.start = e.changedTouches[0].pageX;
        } else {
            self.start = e.pageX;
        }

    }

    this.swiping = function(e) {

        if (self.mousedown) {

            e.preventDefault();
            e.stopPropagation();
            if (typeof e.changedTouches !== 'undefined') {
                var dif = e.changedTouches[0].pageX - self.start;

            } else {
                var dif = e.pageX - self.start;

            }
            container.style.transition = 'none';
            container.style.left = self.mainpos + dif + "px";

        }
    }
	
    this.GoTo = function(gotox) {
        
        container.style.transition = 'all 0.3s';
        if (gotox > 0 && gotox <= container.children.length) {

            self.numx = gotox - 1;
            self.stpx = elem_conts[self.numx].offsetLeft * -1;
            self.mainpos = self.stpx;
            container.style.left = self.mainpos + "px";

        }
    }

    this.swiptoLeft = function() {
        if (self.numx < (container.children.length) - 1) {
            self.numx++;
            self.stpx = elem_conts[self.numx].offsetLeft * -1;
        }
        self.swipp();
    }


    this.swiptoRight = function() {
        if (self.numx > 0) {
            self.numx--;
            self.stpx = elem_conts[self.numx].offsetLeft * -1;
        }
        self.swipp();
    }
  
   this.swipp = function() {
        self.mainpos = self.stpx;
        container.style.left = self.mainpos + "px";
	   if (typeof self.onSwipe !== 'undefined') {
		   self.onSwipe(self.numx,fields.items[self.numx]);
	   }
		
    }
	
    this.swipEnd = function(e) {
        self.mousedown = false;
        if (typeof e.changedTouches !== 'undefined') {
            var dif = e.changedTouches[0].pageX - self.start;
        } else {
            var dif = e.pageX - self.start;
        }
        self.mainpos = self.mainpos + dif;
        container.style.transition = 'all 0.3s';
        var maxallowed = container.children.length - 1;
        var minallowed = 0;
        var elemoffset = 0;
		
        if (dif < 0) {
            self.swiptoLeft();
        } else if (dif > 0) {
            self.swiptoRight();
        } else if (dif==0) {
			if (typeof self.onClick !== 'undefined') {
				self.onClick(self.numx,fields.items[self.numx]);
			} 
		}
	   
    }

    this.mouseout = function(e) {

        if (self.mousedown) {
            self.swipEnd(e);
        }

    }

    this.resizeFix = function() {
        self.start = 0;
        self.stpx = elem_conts[self.numx].offsetLeft * -1;
		self.mainpos = self.stpx;
        container.style.left = self.stpx + "px";
    }



    //mouse	
    this.HTMLElement.addEventListener("mousedown", this.swipStart, true)
    this.HTMLElement.addEventListener("mousemove", this.swiping, true)
    this.HTMLElement.addEventListener("mouseup", this.swipEnd, true)
    this.HTMLElement.addEventListener("mouseout", this.mouseout, true)

    //touch	
    this.HTMLElement.addEventListener("touchstart", this.swipStart, true)
    this.HTMLElement.addEventListener("touchmove", this.swiping, true)
    this.HTMLElement.addEventListener("touchend", this.swipEnd, true)

    window.addEventListener("resize", function(e) {
		if (typeof self !== 'undefined') {
            self.resizeFix()
		}
    });

    return this;
}
