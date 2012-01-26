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
        var upM = false;
        var upC = false;
        var menu = $('#menu');
        var menuToggleImg = $('#menuToggle');
        var content = $('#content');
        var galleryContent = $("#galleri-carousel");
        var galleryContainer = $(".galleri-carousel");
        var galleryNotSet = true;
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
            
            $.ajax({
                url: '<?php print URL_ROOT; ?>interact.php',
                type: 'POST',
                data: {action: 'portfolio_getImages', portfolio_id: projectId},
                dataType: 'json',
                success: function(json) {
                    var imageList = "";
                    var pathPrefix = "<?php print RESOURCES_ROOT . 'uploads' . DS; ?>";
                    $.each(json, function(i, item) {
                        imageList += '<li>';
                        imageList += '<img width="1280px" height="800px" src="' + pathPrefix + item.img_file + '" alt="' + item.name + '">';
                        imageList += '</li>';
                    });
                    // Load gallery content
                    galleryContainer.html('<ul>' + imageList + '</ul>');
                    // Activate jCarousel for the gallery
                    galleryContainer.jCarouselLite({
                        visible: 1,
                        btnNext: "#nextBtn",
                        btnPrev: "#prevBtn",
                        easing: "elasin",
                        beforeStart: function(a) {
                            $(a).parent().fadeTo(100, 0);
                        },
                        afterEnd: function(a) {
                            $(a).parent().fadeTo(100, 1);
                        }
                    });
                }
            });
        }
        
        content.fadeIn(200);
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
        $('#portofolio').on('click', 'a', function () {
            load_gallery(this);
            return false;
        });
        if (galleryNotSet) {
            load_gallery($('#portofolio a').get(0));
        };
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
                        print '<li><a href="' . $gallery['id'] . '">' . $gallery['name'] . '</a></li>';
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