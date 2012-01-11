class Wagn::Renderer
  define_view(:raw, :name=>'*navbox') do
    #ENGLISH
    %{
<form id="navbox_form" action="/search" onsubmit="return navboxOnSubmit(this)">
  <span id="navbox_background">
    <a id="navbox_image" title="Search" onClick="navboxOnSubmit($('navbox_form'))">&nbsp;</a>
    <input type="text" name="navbox" value="#{ params[:_keyword] || '' }" id="navbox_field" autocomplete="off" />
    #{ #navbox_complete_field('navbox_field')
      content_tag("div", "", :id => "navbox_field_auto_complete", :class => "auto_complete") +
      auto_complete_field('navbox_field', {
        :url =>"/card/auto_complete_for_navbox/",
        :after_update_element => "navboxAfterUpdate" }.update({}))
    }
  </span>
</form>
    }
  end
  alias_view(:raw, {:name=>'*navbox'}, :naked)
end
