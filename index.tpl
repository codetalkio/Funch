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
        var menu = $('#menu');
        var menuToggleImg = $('#menuToggle');
        var content = $('#content');
        var galleryContent = $("#galleri-carousel");
        var galleryContainer = $(".galleri-carousel");
        var galleryUl = $(".galleri-carousel ul");
        var galleryLi = $(".galleri-carousel ul li");
        var galleryNotSet = true;
        var loadingImg = '<div class="slideshow-loading"><img src="<?php print RESOURCES_ROOT; ?>img/load.gif" alt="Loading..."></div>';
        var allImagesList = new Array;
        
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
        function load_gallery(elem, pos) {
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
                    var j = 1;
                    var images = new Array;
                    $.each(json, function(i, item) {
                        var goId = 'gallery-image-' + item.id;
                        j = i;
                        images.push(pathPrefix + item.img_file);
                    });
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
                    $('.galleri-carousel').npFullBgImg(allImagesList[0], {fadeInSpeed: 400, center: false, centerX: true});
                    galleryContainer.fadeIn(400);
                }
            });
        }
        function shift_gallery(direction) {
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
                load_gallery(nextGallery, 'end');
            };
        }
        
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
            $(this).addClass('active-gallery');
            load_gallery(this, 'start');
            return false;
        });
        $('#slideshow').on('click', '#nextBtn', function () {
            var allImages = $(".image-list-ul").html().split('/');
            j = parseInt(allImages[1]);
            newImageNum = parseInt(allImages[0]) + 1;
            if (newImageNum > j) {
                shift_gallery('next');
            } else {
                $(".image-list-ul").html(newImageNum + ' / ' + j);
                $('.galleri-carousel').npFullBgImg(allImagesList[parseInt(allImages[0])], {fadeInSpeed: 400, center: false, centerX: true});
            }
        });
        $('#slideshow').on('click', '#prevBtn', function () {
            var allImages = $(".image-list-ul").html().split('/');
            j = parseInt(allImages[1]);
            newImageNum = parseInt(allImages[0]) - 1;
            if (newImageNum < 1) {
                shift_gallery('prev');
            } else {
                $(".image-list-ul").html(newImageNum + ' / ' + j);
                $('.galleri-carousel').npFullBgImg(allImagesList[newImageNum - 1], {fadeInSpeed: 400, center: false, centerX: true});
            }
        });
        
        if (galleryNotSet) {
            var firstGallery = $('#portofolio a').get(0);
            $('#portofolio a').removeClass('active-gallery');
            $(firstGallery).addClass('active-gallery');
            load_gallery(firstGallery, 'start');
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
            <div class="galleri-carousel"></div>
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