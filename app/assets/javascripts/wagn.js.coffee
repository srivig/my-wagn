
wagn.initializeEditors = (map) ->
    map = wagn.conf.editorInitFunctionMap unless map?
    $.each map, (selector, fn) ->
      $.each $.find(selector), ->
        fn.call this


jQuery.fn.extend {
  slot: -> @closest '.card-slot'
  setSlotContent: (val) -> @slot().replaceWith val
  notify: (message) -> 
    notice = @slot().find('.notice')
    return false unless notice[0]
    notice.html(message)
    true

  autosave: ->
    slot = @slot()
    return if @attr('no-autosave')
    #might be better to put this href in the html
    href = wagn.root_path + '/card/save_draft/' + slot.attr('card_id')
    $.ajax href, {
      data : { 'card[content]' : @val() },
      complete: (xhr) -> slot.notify('draft saved') 
    }

  setContentFieldsFromMap: (map) ->
    map = wagn.conf.editorContentFunctionMap unless map?
    this_form = $(this)
    $.each map, (selector, fn)-> 
      this_form.setContentFields(selector, fn)
  setContentFields: (selector, fn) ->
    $.each this.find(selector), ->
      $(this).setContentField(fn)     
  setContentField: (fn)->
    field = this.closest('.card-editor').find('.card-content')
    init_val = field.val()
    wagn.func = fn
    wagn.stash = this[0]
    new_val = fn.call this[0]
    field.val new_val
    field.change() if init_val != new_val 
}

#~~~~~ ( EVENTS )

setInterval (-> $('.card-form').setContentFieldsFromMap()), 20000

$(window).load ->
  wagn.initializeEditors()

  $('body').delegate '.standard-slotter', "ajax:success", (event, data) ->
#    warn "standard slotter success"
    $(this).setSlotContent data

  $('body').delegate '.standard-slotter', "ajax:error", (event, xhr) ->
#    warn "standard slotter error"
    result = xhr.responseText
    if xhr.status == 303 #redirect
      window.location=result
    else if xhr.status == 403 #permission denied
      $(this).setSlotContent result
    else 
      $(this).notify result or $(this).setSlotContent result

#  $('body').delegate '.standard-slotter', "ajax:complete", (event, xhr) ->
#    warn "standard slotter complete"

  $('body').delegate 'button.standard-slotter', 'click', ->
    return false if !$.rails.allowAction $(this)
    $.rails.handleRemote($(this))


  $('body').delegate '.card-form', 'submit', ->
    $(this).setContentFieldsFromMap()
    $(this).find('.card-content').attr('no-autosave','true')
    true

  $('.init-editors').live 'ajax:success', ->
    wagn.initializeEditors()

  # might be able to use more of standard-slotter if 
  $('.live-cardtype-field').live 'change', ->
    field = $(this)
    $.ajax field.attr('href'), {
      data: field.closest('form').serialize()
      complete: (xhr, status) ->
        field.setSlotContent xhr.responseText
        wagn.initializeEditors()
    }

  #should eventually work with standard-slotter (if done with views)
  $('.watch-toggle').live 'ajax:success', (event, data) ->
    $(this).closest('.watch-link').html data

  #unify these next two
  $('.edit-cardtype-field').live 'change', ->
    $(this).closest('form').submit()

  $('.set-select').live 'change', ->
    $(this).closest('form').submit()

  $('.autosave .card-content').live 'change', ->
    content_field = $(this)
    setTimeout ( -> content_field.autosave() ), 500


warn = (stuff) -> console.log stuff if console?
