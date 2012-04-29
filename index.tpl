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
    <script src="{% THEME_ROOT %}jquery.npFullBgImg.js" type="text/javascript" charset="utf-8"></script>
    <script>
    !window.jQuery && document.write('<script src="{% JS_ROOT %}jquery-1.7.1.min.js"><\/script>');
    //{% AJAX %}
    $(document).ready(function () {
        var upM = false;
        var upC = false;
        var nextBtn = $('#nextBtn');
        var prevBtn = $('#prevBtn');
        var nav = $('nav');
        var navTable = $('nav table');
        var menu = $('#menu');
        var menuToggleImg = $('#menuToggle');
        var content = $('#content');
        var galleryContent = $("#galleri-carousel");
        var galleryContainer = $(".galleri-carousel");
        var galleryNotSet = true;
        var loadingContainer = $("#slideshow #loading-placeholder");
        var loadingImg = '<div class="slideshow-loading"><div><img src="<?php print RESOURCES_ROOT; ?>img/load.gif" alt="..." /></div></div>';
        var allImagesList = new Array;
        
        loadingContainer.fadeOut(0);
        loadingContainer.html(loadingImg);
        
        var imgOptions = {
            fadeInSpeed: 400,
            center: true,
            centerX: true,
            beforeLoad: function() {
                loadingContainer.fadeIn(200);
            },
            afterLoad: function() {
                loadingContainer.fadeOut(200);
            }
        }
        
        function toggle_menu() {
            if(upM) {
                navTable.removeClass('box-shadow');
                menu.slideDown(200, function() {
                    nav.addClass('box-shadow');
                });
                menuToggleImg.attr('src', '{% THEME_ROOT %}img/minimize.png');
                upM = false;
            } else {
                nav.removeClass('box-shadow');
                menu.slideUp(200, function() {
                    navTable.addClass('box-shadow');
                });
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
        function load_gallery(elem, pos, arrowkeys) {
            var projectId = $(elem).attr('href');
            
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
                    var j = false;
                    var images = new Array;
                    $.each(json, function(i, item) {
                        var goId = 'gallery-image-' + item.id;
                        j = i;
                        images.push(pathPrefix + item.img_file);
                    });
                    if (j === false && arrowkeys == 'up' || j === false && pos == 'end') {
                        shift_gallery('prev', arrowkeys, pos);
                        return;
                    } else if (j === false) {
                        shift_gallery('next', arrowkeys, pos);
                        return;
                    }
                    allImagesList = images;
                    j = j + 1;
                    if (pos == 'end') {
                        var newImageNum = j;
                    } else {
                        var newImageNum = 1;
                    }
                    $(".image-list-ul").remove();
                    $(elem).parent().append('<span class="image-list-ul">' + newImageNum + ' / ' + j + '</span>');
                    // Load gallery content
                    $('.galleri-carousel').npFullBgImg(allImagesList[newImageNum - 1], imgOptions);
                }
            });
        }
        function shift_gallery(direction, arrowkeys, pos) {
            if (!arrowkeys) {
                arrowkeys = false;
            };
            var currentGallery = $('.active-gallery');
            var setNextGallery = false;
            var galleries = $('#portofolio a');
            var numberOfGalleries = galleries.length;
            $('#portofolio a').removeClass('active-gallery');
            if (direction == 'next') {
                $.each($('#portofolio a'), function(i, gallery) {
                    if (setNextGallery) {
                        nextGallery = gallery;
                        setNextGallery = false;
                    };
                    if (gallery == currentGallery[0] && (i+1) != numberOfGalleries) {
                        setNextGallery = true;
                    } else if (gallery == currentGallery[0] && (i+1) == numberOfGalleries) {
                        nextGallery = galleries[0];
                    };
                });
                $(nextGallery).addClass('active-gallery');
                load_gallery(nextGallery, 'start');
            } else if (direction == 'prev') {
                $.each($('#portofolio a'), function(i, gallery) {
                    if (gallery == currentGallery[0] && (i) >= 1) {
                        nextGallery = galleries[i - 1];
                    } else if (gallery == currentGallery[0] && (i) == 0) {
                        nextGallery = galleries[numberOfGalleries - 1];
                    };
                });
                $(nextGallery).addClass('active-gallery');
                if (arrowkeys) {
                    if (pos == 'end') {
                        load_gallery(nextGallery, 'end', arrowkeys);
                    } else {
                        load_gallery(nextGallery, 'start', arrowkeys);
                    }
                } else {
                    load_gallery(nextGallery, 'end');
                }
            };
        }
        function next_image() {
            var allImages = $(".image-list-ul").html().split('/');
            j = parseInt(allImages[1]);
            newImageNum = parseInt(allImages[0]) + 1;
            if (newImageNum > j) {
                shift_gallery('next');
            } else {
                $(".image-list-ul").html(newImageNum + ' / ' + j);
                $('.galleri-carousel').npFullBgImg(allImagesList[parseInt(allImages[0])], imgOptions);
            }
            upC = false;
            toggle_content();
        }
        function prev_image() {
            var allImages = $(".image-list-ul").html().split('/');
            j = parseInt(allImages[1]);
            newImageNum = parseInt(allImages[0]) - 1;
            if (newImageNum < 1) {
                shift_gallery('prev', 'up', 'end');
            } else {
                $(".image-list-ul").html(newImageNum + ' / ' + j);
                $('.galleri-carousel').npFullBgImg(allImagesList[newImageNum - 1], imgOptions);
            }
            upC = false;
            toggle_content();
        }
        
        $('#menuToggle').click(function () {
            toggle_menu();
        });
        $('#contentToggle').click(function () {
            toggle_content();
        });
        $('.ajax-menu a').bind('click', function () {
            content.fadeIn();
            upC = false;
        });
        $('#portofolio > li a').bind('click', function () {
            $('#portofolio a').removeClass('active-gallery');
            $(this).addClass('active-gallery');
            load_gallery(this, 'start');
            return false;
        });
        nextBtn.bind('click', function () {
            next_image();
        });
        prevBtn.bind('click', function () {
            prev_image();
        });
        
        $(document).keydown(function (e) {
            if (e.keyCode == 37) { 
                prev_image(); // Left arrow
            } else if (e.keyCode == 39) {
                next_image(); // Right arrow
            } else if (e.keyCode == 38) {
                shift_gallery('prev', 'up', 'start');
            } else if (e.keyCode == 40) {
                shift_gallery('next', 'down', 'start');
            }
        });
        
        $(document).mousemove(function(e){
            var windowHeight = $(window).height();
            var windowWidth = $(window).width();
            var windowX = windowWidth / 2;
            if (e.pageX < windowX || e.pageX > (windowWidth - 20) || e.pageY < 20 || e.pageY > (windowHeight - 20)) {
                nextBtn.fadeOut(100);
            } else {
                nextBtn.fadeIn(100);
            }
            if (e.pageX > windowX || e.pageX < 20 || e.pageY < 20 || e.pageY > (windowHeight - 20)) {
                prevBtn.fadeOut(100);
            } else {
                prevBtn.fadeIn(100);
            }
        });
        
        if (galleryNotSet) {
            var firstGallery = $('#portofolio a').get(0);
            $('#portofolio a').removeClass('active-gallery');
            $(firstGallery).addClass('active-gallery');
            load_gallery(firstGallery, 'start');
        };
        content.fadeIn(200);
        
        // Align content height with the menu
        var contentHeight = parseInt(content.css('height'));
        var contentExtra = parseInt(content.css('margin-top')) + parseInt(content.css('margin-bottom')) + parseInt(content.css('padding-top')) + parseInt(content.css('padding-bottom')) + parseInt(content.css('border-top-width')) + parseInt(content.css('border-bottom-width'));
        var alignedHeight = parseInt(nav.css('height')) - parseInt(content.css('top')) - contentHeight;
        content.css({height: contentHeight + alignedHeight - contentExtra + 'px'})
    });
    </script>
</head>

<body>
    <div id="container">
        
        <nav class="box-shadow">
            <table>
                <tr>
                    <td colspan="3" class="logo-fill">
                        <img src="{% THEME_ROOT %}img/minimize.png" id="menuToggle" alt="Minimize" />
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
                    foreach ($portfolio->get(null, 'ORDER BY weight ASC') as $gallery) {
                        print '<li><a class="gallery-anchor" href="' . $gallery['id'] . '">' . $gallery['name'] . '</a></li>';
                    }
                    ?>
                </ul>
            </div>
        </nav>

        <div id="content">
                <img src="{% THEME_ROOT %}img/close.png" id="contentToggle" alt="Close" />
                <div class="ajax-content">
                    {% CONTENT %}
                </div>
        </div>

        <div id="slideshow">
            <div id="loading-placeholder"></div>
            <div class="galleri-carousel"></div>
            <span id="prevBtn" class="arrow previous"><img src="{% THEME_ROOT %}img/arrow-left.png" alt="Previous" /></span>
            <span id="nextBtn" class="arrow next"><img src="{% THEME_ROOT %}img/arrow-right.png" alt="Next" /></span>
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