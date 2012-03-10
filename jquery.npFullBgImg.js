<?php 
ob_start ("ob_gzhandler");
header("Content-type: text/javascript; charset: UTF-8");
header("Cache-Control: must-revalidate");
$offset = 60 * 60 * 60 ;
$ExpStr = "Expires: " . 
gmdate("D, d M Y H:i:s",
time() + $offset) . " GMT";
header($ExpStr);
?>
/* JS
 * Copyright 2009 noponies.
 * Version 0.1 Beta - Intial Release to the wild - comments, yes please!
 *
 * Example: jQuery('#imgContainer').npFullBgImg("files/layout2011/gfx/sideChooser.png", {fadeInSpeed: 0, center: false, centerX: true});
 */
(function($){

	var img_prop;
	var imageArray = [];
	var defaults = {};
	var firstLoad = true;
	
	$.fn.extend({ 
		npFullBgImg: function(imgPath, options) {
			defaults = {
				 fadeInSpeed: 1000,
   				 center: false,
				 centerX: false,
                 beforeLoad: false,
                 afterLoad: false,
                 cache: true
			};
			var opts = $.extend(defaults, options);
			var targetContainer = $(this); 
			//create image
			var img  = new Image();
			//add to array
 	 		imageArray.unshift(img);
 	 		
 	 		if(firstLoad === true) {
 	 			$(targetContainer).fadeTo(10, 0)
 	 		}
            
            if (opts.beforeLoad) {
                if(typeof opts.beforeLoad === 'function') {
                    opts.beforeLoad.call(this);
                }
            }
            $.ajaxSetup ({
                cache: opts.cache
            });
	        $(img).load(function () {
	        	//this is a hack to stop a flash of the image sometimes
  				$(img).fadeOut(10, 0);
	         	//$(img).css({display: 'none', left:0, top: 0, position: 'fixed', 'z-index': -100});
	         	$(img).css({display: 'none', left:0, top: 0, position: 'fixed', 'z-index': 0});
	            //add image to container
	            $(targetContainer).append(img);
	            //resize image

				resizeImg($(window).width(), $(window).height(), $(img).width(), $(img).height());
                
				if(firstLoad === true) {
 	 				$(targetContainer).fadeTo(10, 1)
 	 				firstLoad = false;
 	 			}
					            
	            $(img).fadeIn(defaults.fadeInSpeed, function () {
		            if(imageArray.length > 1) {
		            	imageArray.pop();
		            	$(targetContainer).children().eq(0).remove();   	
		            }
		            
		          	if( typeof opts.callback == 'function' ){
						opts.callback.call(this, targetContainer, options);
					}
                    if (opts.afterLoad) {
                        if(typeof opts.afterLoad === 'function') {
                            opts.afterLoad.call(this);
                        }
                    }
	            });
	        }).error(function () {
	            //console.log('image not loaded');
	        }).attr('src', imgPath);
	        
	    	}
		});
	
	$(window).bind("resize", function(){
			resizeImg($(window).width(), $(window).height(), $(imageArray[0]).width(), $(imageArray[0]).height());	  			
	});

  	function resizeImg(sw, sh, imgw, imgh, targetContainer){
			if ((sh / sw) > (imgh / imgw)) {
					img_prop = imgw/imgh;
					destHeight = sh;
					destWidth = sh * img_prop;
				} else {
					img_prop = imgh/imgw;
					destWidth = sw;
					destHeight = sw * img_prop;
				}

			$(imageArray[0]).attr({
				width: destWidth,
				height: destHeight
			});
			
			if(defaults.center) {
				var xVal = sw * .5 - $(imageArray[0]).width() * .5;
				var yVal = sh * .5 - $(imageArray[0]).height() * .5;
				$(imageArray[0]).css({left:xVal, top: yVal});
			} else if (defaults.centerX) {
				var xVal = sw * .5 - $(imageArray[0]).width() * .5;
				$(imageArray[0]).css({left:xVal});
			}
	}

	
})(jQuery);
