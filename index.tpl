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
    <script>
    !window.jQuery && document.write('<script src="{% JS_ROOT %}jquery-1.7.1.min.js"><\/script>');
    //{% AJAX %}
    $(document).ready(function () {
        var upM = false;
        function toggle_menu() {
            if(upM) {
                $('#menu').slideDown(200);
                upM = false;
            } else {
                $('#menu').slideUp(200);
                upM = true;
            }
        }
        var upC = false;
        function toggle_content() {
            if(upC) {
                $('#content').fadeIn();
                upC = false;
            } else {
                $('#content').fadeOut();
                upC = true;
            }
        }
        
        $('#content').fadeIn(200);
        $('#menuToggle').click(function () {
            toggle_menu();
        });
        $('#contentToggle').click(function () {
            toggle_content();
        });

        $('.ajax-menu').on('click', 'a', function () {
            $('#content').fadeIn();
            upC = false;
        });
        $('#portofolio').on('click', 'a', function () {
            var projectId = $(this).attr('href');
            var loadingImg = '<div class="slideshow-loading"><img src="<?php print RESOURCES_ROOT; ?>img/load.gif" alt="Loading..."></div>';
            var imgStyle = 'style="width:100%;"';
            
            $("#slideshow ul").html(loadingImg);
            
            $.ajax({
                url: '<?php print URL_ROOT; ?>interact.php',
                type: 'POST',
                data: {action: 'portfolio_getImages', portfolio_id: projectId},
                dataType: 'json',
                success: function(json) {
                    console.log(json);
                    var imageList = "";
                    var pathPrefix = "<?php print RESOURCES_ROOT . 'uploads' . DS; ?>";
                    $.each(json, function(i, item) {
                        imageList += '<li>';
                        imageList += '<img ' + imgStyle + ' src="' + pathPrefix + item.img_file + '">';
                        imageList += '</li>';
                    });
                    $("#slideshow ul").html(imageList);
                }
            });
            return false;
        }); 
    });
    </script>
</head>

<body>
    <div id="container">
        <nav>
            <table>
                <tr>
                    <td colspan="3" class="logo-fill">
                        <img src="{% IMG_ROOT %}icons/close.png" id="menuToggle">
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
                <ul id="menu" class="ajax-menu">
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
                <img src="{% IMG_ROOT %}icons/close.png" id="contentToggle">
                <div class="ajax-content">
                    {% CONTENT %}
                </div>
        </div>

        <div id="slideshow">
            <ul>
            </ul>
            <span class="arrow previous"></span>
            <span class="arrow next"></span>
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