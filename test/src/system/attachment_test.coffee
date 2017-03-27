{after, assert, clickElement, defer, dragToCoordinates, moveCursor, pressKey, test, testGroup, triggerEvent, typeCharacters} = Trix.TestHelpers

testGroup "Attachments", template: "editor_with_image", ->
  test "moving an image by drag and drop", (expectDocument) ->
    typeCharacters "!", ->
      moveCursor direction: "right", times: 1, (coordinates) ->
        img = document.activeElement.querySelector("img")
        triggerEvent(img, "mousedown")
        defer ->
          dragToCoordinates coordinates, ->
            expectDocument "!a#{Trix.OBJECT_REPLACEMENT_CHARACTER}b\n"

  test "removing an image", (expectDocument) ->
    after 20, ->
      clickElement getFigure(), ->
        closeButton = getAttachmentButton(attachmentClassNames().removeButton)

        clickElement closeButton, ->
          expectDocument "ab\n"

  test "editing an image caption", (expectDocument) ->
    after 20, ->
      clickElement getFigure(), ->
        clickElement findElement("figcaption"), ->
          defer ->
            assert.ok findElement("textarea")
            findElement("textarea").focus()
            findElement("textarea").value = "my caption"
            pressKey "return", ->
              assert.notOk findElement("textarea")
              assert.textAttributes [2, 3], caption: "my caption"
              assert.locationRange index: 0, offset: 3
              expectDocument "ab#{Trix.OBJECT_REPLACEMENT_CHARACTER}\n"

  test "editing an attachment caption with no filename", (done) ->
    after 20, ->
      # Caption is initially empty
      captionElement = findElement("figcaption")
      assert.equal captionElement.clientHeight, 0
      assert.equal getCaptionContent(captionElement), ""

      clickElement getFigure(), ->
        # Caption prompt is displayed when editing attachment
        captionElement = findElement("figcaption")
        assert.ok captionElement.clientHeight > 0
        assert.equal getCaptionContent(captionElement), Trix.config.lang.captionPrompt
        done()

  test "aligning and re-aligning an attachment", (done) ->
    after 20, ->
      assert.equal getFigure().classList.value, "attachment attachment-preview attachment-clear"

      clickElement getFigure(), ->
        leftAlignButton = getAttachmentButton(attachmentClassNames().leftAlignButton)
        clearAlignButton = getAttachmentButton(attachmentClassNames().clearAlignButton)
        rightAlignButton = getAttachmentButton(attachmentClassNames().rightAlignButton)

        clickElement leftAlignButton, ->
          assert.equal getFigure().classList.value, "attachment attachment-preview attachment-left"

        defer ->
          clickElement clearAlignButton, ->
            assert.equal getFigure().classList.value, "attachment attachment-preview attachment-clear"

          defer ->
            clickElement rightAlignButton, ->
              assert.equal getFigure().classList.value, "attachment attachment-preview attachment-right"
              done()

getFigure = ->
  findElement("figure")

findElement = (selector) ->
  getEditorElement().querySelector(selector)

getCaptionContent = (element) ->
  element.textContent or getPseudoContent(element)

attachmentClassNames = ->
  Trix.config.css.classNames.attachment

getAttachmentButton = (buttonClass) ->
  getFigure().querySelector(".#{buttonClass.split(" ").join(".")}")

getPseudoContent = (element) ->
  before = getComputedStyle(element, "::before").content
  after = getComputedStyle(element, "::after").content

  content =
    if before and before isnt "none"
      before
    else if after and after isnt "none"
      after
    else
      ""

  content.replace(/^['"]/, "").replace(/['"]$/, "")
