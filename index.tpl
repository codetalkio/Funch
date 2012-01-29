<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{% SITE_TITLE %}</title>
    <link rel="stylesheet" type="text/css" media="screen, print, projection" href="{% STYLESHEET %}">
    <link rel="shortcut icon" type="image/x-icon" href="{% FAVICON %}">
    <!--[if lt IE 9]>
    <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js" type="text/javascript" charset="utf-8"></script>
    <script src="{% JS_ROOT %}head.load.min.js" type="text/javascript" charset="utf-8"></script>
    <script src="{% THEME_ROOT %}jcarousellite_1.0.1.min.js" type="text/javascript" charset="utf-8"></script>
    <script src="{% THEME_ROOT %}jquery.easing.1.3.js" type="text/javascript" charset="utf-8"></script>
    <script src="{% THEME_ROOT %}jquery.easing.compatibility.js" type="text/javascript" charset="utf-8"></script>
    <script>
    !window.jQuery && document.write('<script src="{% JS_ROOT %}jquery-1.7.1.min.js"><\/script>');
    //{% AJAX %}
    $(document).ready(function () {
        var w=window,d=document,e=d.documentElement,g=d.getElementsByTagName('body')[0],x=w.innerWidth||e.clientWidth||g.clientWidth,y=w.innerHeight||e.clientHeight||g.clientHeight;
        var y = y * imageRatio;
        var originalX = x;
        var imageRatio = 800 / 1280;
        var upM = false;
        var upC = false;
        var menu = $('#menu');
        var menuToggleImg = $('#menuToggle');
        var content = $('#content');
        var galleryContent = $("#galleri-carousel");
        var galleryContainer = $(".galleri-carousel");
        var galleryUl = $(".galleri-carousel ul");
        var galleryLi = $(".galleri-carousel ul li");
        var galleryNotSet = true;
        var originalUlLeft = 1280;
        var loadingImg = '<div class="slideshow-loading"><img src="<?php print RESOURCES_ROOT; ?>img/load.gif" alt="Loading..."></div>';
        
        function toggle_menu() {
            if(upM) {
                menu.slideDown(200);
                menuToggleImg.attr('src', '{% THEME_ROOT %}img/minimize.png');
                upM = false;
            } else {
                menu.slideUp(200);
                menuToggleImg.attr('src', '{% THEME_ROOT %}img/expand.png');
                upM = true;
            }
        }
        function toggle_content() {
            if(upC) {
                content.fadeIn();
                upC = false;
            } else {
                content.fadeOut();
                upC = true;
            }
        }
        function load_gallery(elem) {
            var projectId = $(elem).attr('href');
            
            $("#slideshow #loading-placeholder").html(loadingImg);
            galleryContainer.fadeOut(0);
            
            $.ajax({
                url: '<?php print URL_ROOT; ?>interact.php',
                type: 'POST',
                data: {action: 'portfolio_getImages', portfolio_id: projectId},
                dataType: 'json',
                success: function(json) {
                    var goArray = new Array();
                    var goList = "";
                    var imageList = "";
                    var pathPrefix = "<?php print RESOURCES_ROOT . 'uploads' . DS; ?>";
                    w=window,d=document,e=d.documentElement,g=d.getElementsByTagName('body')[0],x=w.innerWidth||e.clientWidth||g.clientWidth,y=w.innerHeight||e.clientHeight||g.clientHeight;
                    y = x * imageRatio;
                    $.each(json, function(i, item) {
                        var goId = 'gallery-image-' + item.id;
                        goArray[i] = '#' + goId;
                        j = i + 1;
                        if (i == 0) {
                            goList += '<li><a href="" id="' + goId + '" class="active-gallery-image">' + j + '.</a></li>';
                        } else {
                            goList += '<li><a href="" id="' + goId + '">' + j + '.</a></li>';
                        }
                        
                        imageList += '<li image="' + goId + '">';
                        imageList += '<img class="gallery-image" width="' 
                                  + x + 'px" height="' + y + 'px" src="' 
                                  + pathPrefix + item.img_file 
                                  + '" alt="' + item.name + '">';
                        imageList += '</li>';
                    });
                    $(".image-list-ul").remove();
                    $(elem).parent().append('<ul class="image-list-ul">' + goList + '</ul>');
                    // Load gallery content
                    galleryContainer.html('<ul>' + imageList + '</ul>');
                    galleryContainer.fadeIn(200);
                    // Activate jCarousel for the gallery
                    galleryContainer.jCarouselLite({
                        visible: 1,
                        btnNext: "#nextBtn",
                        btnPrev: "#prevBtn",
                        btnGo: goArray,
                        beforeStart: function(a) {
                            $(a).parent().fadeTo(100, 0);
                        },
                        afterEnd: function(a) {    
                            var targetImgLink = $(a).attr('image');
                            $("[id^=gallery-image-]").removeClass('active-gallery-image');
                            $('#' + targetImgLink).attr('class', 'active-gallery-image');
                            w=window,d=document,e=d.documentElement,g=d.getElementsByTagName('body')[0],x=w.innerWidth||e.clientWidth||g.clientWidth,y=w.innerHeight||e.clientHeight||g.clientHeight;
                            y = x * imageRatio;
                            // This is to adjust the jCarousel dom element
                            ulWidth = $(".galleri-carousel ul li").length * x;
                            var curLeft = $(".active-gallery-image").html().split('.');
                            var newLeft = x * parseFloat(curLeft[0]) * -1;
                            $(".galleri-carousel ul").css({"width":ulWidth, "left":newLeft});
                            
                            $(a).parent().fadeTo(250, 1);
                        }
                    });
                    originalUlLeft = $(".galleri-carousel ul").css("left");
                }
            });
        }
        
        $(window).resize(function() {
            w=window,d=document,e=d.documentElement,g=d.getElementsByTagName('body')[0],x=w.innerWidth||e.clientWidth||g.clientWidth,y=w.innerHeight||e.clientHeight||g.clientHeight;
            y = x * imageRatio;
            // This is to adjust the jCarousel dom element
            ulWidth = $(".galleri-carousel ul li").length * x;
            var curLeft = $(".active-gallery-image").html().split('.');
            var newLeft = x * parseFloat(curLeft[0]) * -1;
            
            $(".galleri-carousel ul").css({"width":ulWidth, "left":newLeft});
            galleryContainer.css({"width":x, "height":y});
            $(".galleri-carousel ul li").css({"width":x, "height":y});
            $(".gallery-image").css({"width":x, "height":y});
            $(".gallery-image").attr({"width":x, "height":y});
        });
        $('#menuToggle').click(function () {
            toggle_menu();
        });
        $('#contentToggle').click(function () {
            toggle_content();
        });
        $('.ajax-menu').on('click', 'a', function () {
            content.fadeIn();
            upC = false;
        });
        $('#portofolio > li').on('click', 'a', function () {
            $('#portofolio a').removeClass('active-gallery');
            $(this).attr('class', 'active-gallery');
            load_gallery(this);
            return false;
        });
        
        if (galleryNotSet) {
            var firstGallery = $('#portofolio a').get(0);
            $('#portofolio a').removeClass('active-gallery');
            $(firstGallery).attr('class', 'active-gallery');
            load_gallery(firstGallery);
        };
        content.fadeIn(200);
    });
    </script>
</head>

<body>
    <div id="container">
        
        <nav>
            <table>
                <tr>
                    <td colspan="3" class="logo-fill">
                        <img src="{% THEME_ROOT %}img/minimize.png" id="menuToggle">
                    </td>
                </tr>
                <tr>
                    <td class="logo-fill fill-middle"> </td>
                    <td id="logo"></td>
                    <td class="logo-fill fill-middle"> </td>
                </tr>
                <tr>
                    <td colspan="3" class="logo-fill"></td>
                </tr>
            </table>
            <div id="menu">
                <ul class="ajax-menu">
                <?php
                    foreach (Pages::getMenu() as $menu) {
                        print '<li><a ' . $menu['active'] . ' href="' . $menu['href'] . '">' . $menu['name'] . '</a></li>';
                    }
                ?>
                </ul>

                <ul id="portofolio">
                    <?php
                    $portfolio = new Portfolio;
                    foreach ($portfolio->get() as $gallery) {
                        print '<li><a class="gallery-anchor" href="' . $gallery['id'] . '">' . $gallery['name'] . '</a></li>';
                    }
                    ?>
                </ul>
            </div>
        </nav>

        <div id="content">
                <img src="{% THEME_ROOT %}img/close.png" id="contentToggle">
                <div class="ajax-content">
                    {% CONTENT %}
                </div>
        </div>

        <div id="slideshow">
            <div id="loading-placeholder"></div>
            <div class="galleri-carousel">
                <ul id="galleri-carousel"></ul>
            </div>
            <span id="prevBtn" class="arrow previous"></span>
            <span id="nextBtn" class="arrow next"></span>
        </div>
        
    </div>
    
    <footer>
        Copyright &copy; 2009 - 2011 Christian Laustsen, 
        <a href="{% URL_ROOT %}LICENSE">All rights reserved</a> |
        <a href="{% URL_ROOT %}admin">Administration</a>
    </footer>
    {% GOOGLE_ANALYTICS %}
</body>
</html>