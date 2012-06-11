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
        var upM = false,
            upC = false,
            imgIsLoading = false,
            nextBtn = $('#nextBtn'),
            prevBtn = $('#prevBtn'),
            imageInfoBackground = $('#image-info-background'),
            imageInfo = $('#image-info'),
            nav = $('nav'),
            navTable = $('nav table'),
            menu = $('#menu'),
            menuToggleImg = $('#menuToggle'),
            content = $('#content'),
            $navigation = $("#navigation-section"),
            galleryContent = $("#galleri-carousel"),
            galleryContainer = $(".galleri-carousel"),
            galleryNotSet = true,
            loadingContainer = $("#slideshow #loading-placeholder"),
            loadingImg = '<div class="slideshow-loading"><div><img src="<?php print RESOURCES_ROOT; ?>img/load.gif" alt="..." /></div></div>',
            allImagesList = new Array,
            imageInfoList = new Array;
        
        loadingContainer.fadeOut(0);
        loadingContainer.html(loadingImg);
        
        var imgOptions = {
            fadeInSpeed: 400,
            center: true,
            centerX: true,
            beforeLoad: function() {
                $(document).trigger('IMAGE_IS_LOADING');
            },
            afterLoad: function() {
                $(document).trigger('IMAGE_IS_DONE_LOADING');
            }
        }
        
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
                    var imagesInfo = new Array;
                    $.each(json, function(i, item) {
                        var goId = 'gallery-image-' + item.id;
                        j = i;
                        var imageSrc = pathPrefix + item.img_file;
                        images.push(imageSrc);
                        imagesInfo.push({
                            id: item.id,
                            imageSrc: imageSrc,
                            name: item.name,
                            description: item.description
                        });
                    });
                    if (j === false && arrowkeys == 'up' || j === false && pos == 'end') {
                        shift_gallery('prev', arrowkeys, pos);
                        return;
                    } else if (j === false) {
                        shift_gallery('next', arrowkeys, pos);
                        return;
                    }
                    allImagesList = images;
                    imageInfoList = imagesInfo;
                    j = j + 1;
                    if (pos == 'end') {
                        var newImageNum = j;
                    } else {
                        var newImageNum = 1;
                    }
                    $(".image-list-ul").remove();
                    $(elem).parent().append('<span class="image-list-ul">' + newImageNum + ' / ' + j + '</span>');
                    // Load gallery content
                    var info = {};
                    for (var i=0; i < imageInfoList.length; i++) {
                        if (allImagesList[newImageNum - 1] == imageInfoList[i].imageSrc) {
                            $(document).trigger('CHANGE_IMAGE_INFO', imageInfoList[i]);
                        }
                    };
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
                for (var i=0; i < imageInfoList.length; i++) {
                    if (allImagesList[parseInt(allImages[0])] == imageInfoList[i].imageSrc) {
                        $(document).trigger('CHANGE_IMAGE_INFO', imageInfoList[i]);
                    }
                };
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
                for (var i=0; i < imageInfoList.length; i++) {
                    if (allImagesList[newImageNum - 1] == imageInfoList[i].imageSrc) {
                        $(document).trigger('CHANGE_IMAGE_INFO', imageInfoList[i]);
                    }
                };
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
            // Right side
            if (e.pageX < windowX || e.pageX > (windowWidth - 20) || e.pageY < 20 || e.pageY > (windowHeight - 20)) {
                nextBtn.fadeOut(100);
            } else {
                nextBtn.fadeIn(100);
            }
            // Left side
            if (e.pageX > windowX || e.pageX < 20 || e.pageY < 20 || e.pageY > (windowHeight - 20)) {
                prevBtn.fadeOut(100);
            } else {
                prevBtn.fadeIn(100);
            }
            // Bottom
            if (e.pageY > (windowHeight - 100)) {
                imageInfoBackground.fadeIn(200);
                imageInfo.fadeIn(200);
            } else {
                imageInfoBackground.fadeOut(200);
                imageInfo.fadeOut(200);
            }
        });
        
        $(document).on('IMAGE_IS_LOADING', function() {
            loadingContainer.fadeIn(200);
            imgIsLoading = true;
        });
        
        $(document).on('IMAGE_IS_DONE_LOADING', function() {
            loadingContainer.fadeOut(200);
            imgIsLoading = false;
        });
        
        $(document).on('CHANGE_IMAGE_INFO', function(e, imageData) {
            imageInfo.html(imageData.name);
        });
        
        if (galleryNotSet) {
            var firstGallery = $('#portofolio a').get(0);
            $('#portofolio a').removeClass('active-gallery');
            $(firstGallery).addClass('active-gallery');
            load_gallery(firstGallery, 'start');
        };
        content.fadeIn(200);
        
        var btnPos = String(($(window).height() / 2) - (47 / 2)) + 'px';
        nextBtn.css({top: btnPos});
        prevBtn.css({top: btnPos});
        
        $(window).resize(function() {
            var btnPos = String(($(window).height() / 2) - (47 / 2)) + 'px';
            nextBtn.css({top: btnPos});
            prevBtn.css({top: btnPos});
        });
    });
    </script>
</head>

<body>
    <div id="container">
        
        <nav id="navigation-section">
            <table>
                <tr>
                    <td class="menu-top">
                        <img src="{% THEME_ROOT %}img/minimize.png" id="menuToggle" alt="Minimize" />
                    </td>
                </tr>
                <tr>
                    <td class="menu-middle">
                        <div id="menu">
                            <ul class="ajax-menu">
                            <?php
                                foreach (Pages::getMenu() as $menu) {
                                    print '<li><a ' . $menu['active'] . ' href="' . $menu['href'] . '">' . $menu['name'] . '</a>&nbsp;&nbsp;</li>';
                                }
                            ?>
                            </ul>

                            <ul id="portofolio">
                                <?php
                                $portfolio = new Portfolio;
                                foreach ($portfolio->get(null, 'ORDER BY weight ASC') as $gallery) {
                                    print '<li><a class="gallery-anchor" href="' . $gallery['id'] . '">' . $gallery['name'] . '</a>&nbsp;&nbsp;</li>';
                                }
                                ?>
                            </ul>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="menu-bottom"></td>
                </tr>
            </table>
            <div id="content">
                    <img src="{% THEME_ROOT %}img/minimize.png" id="contentToggle" alt="Close" />
                    <div class="ajax-content">
                        {% CONTENT %}
                    </div>
            </div>
        </nav>

        <div id="slideshow">
            <div id="loading-placeholder"></div>
            <div class="galleri-carousel"></div>
            <span id="prevBtn" class="arrow previous"><img src="{% THEME_ROOT %}img/arrow-left.png" alt="Previous" /></span>
            <span id="nextBtn" class="arrow next"><img src="{% THEME_ROOT %}img/arrow-right.png" alt="Next" /></span>
            <div id="image-info-background"> </div>
            <div id="image-info"> </div>
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