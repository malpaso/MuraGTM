component name='eventHandler' accessors='true' extends='mura.plugin.pluginGenericEventHandler' output='false' {

  property name='$';

  this.pluginName = 'MuraGTM';

  public any function onApplicationLoad(required struct $) {
    // Register all event handlers/listeners of this .cfc with Mura CMS
    variables.pluginConfig.addEventHandler(this);
  }

  public any function onRenderEnd(required struct $){
    var html = '';
    var comment = '<!-- MuraGTM : %%message%% -->';
    var google_tag_manager = variables.pluginConfig.getSetting('GTMID');

    if(google_tag_manager != ''){
      savecontent variable='gtm' { include 'inc/gtm.cfm'; }
      gtm = replaceNoCase(gtm,'%%GTMID%%',google_tag_manager,'ALL');
      html &= gtm;
    }

    if(html != ''){
      try{
        var jSoup = createObject('java','org.jsoup.Jsoup');
        var doc = jSoup.parse( $.event("__MuraResponse__") );
        var newBody = doc.select('body');
        newBody.prepend(gtm);
        var newBodyContent = doc.html();
        // var newContent = replaceNoCase($.event("__MuraResponse__"), "</body>", newBodyContent & "</body>");
        $.event("__MuraResponse__", newBodyContent);
      }catch( any e ){
        var newContent = replaceNoCase($.event("__MuraResponse__"), "</body>", replace(comment,'%%message%%',e.message) & "</body>");
        $.event("__MuraResponse__", newContent);
      }
    }
  }
}
