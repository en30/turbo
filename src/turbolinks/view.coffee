#= require turbolinks/snapshot

class Turbolinks.View
  constructor: (@delegate) ->

  loadHTML: (html) ->
    snapshot = Turbolinks.Snapshot.fromHTML(html)
    @loadSnapshotByScrollingToSavedPosition(snapshot, "anchor")

  loadSnapshotByScrollingToSavedPosition: (snapshot, scrollToSavedPosition) ->
    @loadSnapshot(snapshot)
    @scrollSnapshotToSavedPosition(snapshot, scrollToSavedPosition)

  saveSnapshot: ->
    getSnapshot(true)

  # Private

  loadSnapshot: (newSnapshot) ->
    currentSnapshot = getSnapshot(false)

    unless currentSnapshot.hasSameRemoteHeadElementsAsSnapshot(newSnapshot)
      return window.location.reload()

    for element in newSnapshot.getInlineHeadElementsNotPresentInSnapshot(currentSnapshot)
      document.head.appendChild(element.cloneNode(true))

    for element in currentSnapshot.getTemporaryHeadElements()
      document.head.removeChild(element)

    for element in newSnapshot.getTemporaryHeadElements()
      document.head.appendChild(element.cloneNode(true))

    newBody = newSnapshot.body.cloneNode(true)
    importPermanentBodyElements(newBody, currentSnapshot.getPermanentBodyElements())
    document.body = newBody

  scrollSnapshotToSavedPosition: (snapshot, scrollToSavedPosition) ->
    location = window.location.toString()

    if scrollToSavedPosition and snapshotOffsets?
      xOffset = snapshot.scrollLeft
      yOffset = snapshot.scrollTop
      scrollTo(xOffset, yOffset)
    else if element = (try document.querySelector(window.location.hash))
      element.scrollIntoView()
    else if @lastScrolledLocation isnt location
      scrollTo(0, 0)

    @lastScrolledLocation = location

  getSnapshot = (clone) ->
    new Turbolinks.Snapshot
      head: maybeCloneElement(document.head, clone)
      body: maybeCloneElement(document.body, clone)
      scrollLeft: window.pageXOffset
      scrollTop: window.pageYOffset

  importPermanentBodyElements = (body, permanentBodyElements) ->
    for newChild in permanentBodyElements
      if oldChild = body.querySelector("[id='#{newChild.id}']")
        oldChild.parentNode.replaceChild(newChild, oldChild)

  maybeCloneElement = (element, clone) ->
    if clone then element.cloneNode(true) else element
