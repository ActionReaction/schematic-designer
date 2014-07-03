'use strict'

class Button extends draw2d.SetFigure
  NAME: 'Button'

  init: ->
    super()
    @setDimension 30, 30
    out = new draw2d.OutputPort
    @addPort out
    @setResizeable(false)
    @setUserData category:'action'

  createSet: ->
    set = super()
    set.push @canvas.paper.image 'images/glyphicons/png/glyphicons_220_play_button.png', 0, 0, 128, 128
    set

class Movement extends draw2d.SetFigure
  NAME: 'Movement'

  init: ->
    super()
    @setDimension 30, 30
    out = new draw2d.OutputPort
    @addPort out
    @setResizeable(false)
    @setUserData category:'action'

  createSet: ->
    set = super()
    set.push @canvas.paper.image 'images/glyphicons/png/glyphicons_051_eye_open.png', 0, 0, 128, 128
    set

class Bell extends draw2d.SetFigure
  NAME: 'Bell'

  init: ->
    super()
    @setDimension 30, 30
    ins = new draw2d.InputPort
    @addPort ins
    @setResizeable(false)
    @setUserData category:'reaction'

  createSet: ->
    set = super()
    set.push @canvas.paper.image 'images/glyphicons/png/glyphicons_333_bell.png', 0, 0, 128, 128
    set

class LCD extends draw2d.SetFigure
  NAME: 'LCD'

  init: ->
    super()
    @setDimension 30, 30
    ins = new draw2d.InputPort
    @addPort ins
    @setResizeable(false)
    @setUserData category:'reaction'

  createSet: ->
    set = super()
    set.push @canvas.paper.image 'images/glyphicons/png/glyphicons_323_calculator.png', 0, 0, 128, 128
    set

class Tweet extends draw2d.SetFigure
  NAME: 'Tweet'

  init: ->
    super()
    @setDimension 30, 30
    ins = new draw2d.InputPort
    @addPort ins
    @setResizeable(false)
    @setUserData category:'reaction'

  createSet: ->
    set = super()
    set.push @canvas.paper.image 'images/glyphicons_social/png/glyphicons_social_31_twitter.png', 0, 0, 128, 128
    set

class Text extends draw2d.SetFigure
  NAME: 'Text'

  init: ->
    super()
    @setDimension 30, 30
    @setResizeable false
    @setUserData category:'action'

  createSet: ->
    @set = super()
    @set

class NewText extends Text
  NAME: 'NewText'

  init: ->
    super()
    @addPort new draw2d.OutputPort

  createSet: ->
    @set = super()
    @set.push @canvas.paper.image 'images/glyphicons/png/glyphicons_129_message_new.png', 0, 0, 128, 128

class LabelRectangle extends draw2d.shape.basic.Rectangle
  init: (w, h) ->
    super(w, h)

    @label = new draw2d.shape.basic.Label 'emptehh'
    @label.setColor '#ffffff'
    @addFigure @label, new draw2d.layout.locator.CenterLocator(@)
    @label.installEditor new draw2d.ui.LabelInplaceEditor

  setText: (text) ->
    @label.setText text


class And extends LabelRectangle
  NAME: 'and'

  init: (w, h) ->
    super(w, h)
    @label.setText 'AND'

    in1 = new draw2d.InputPort
    in2 = new draw2d.InputPort
    out1 = new draw2d.OutputPort
    @addPort in1
    @addPort in2
    @addPort out1
    @setResizeable(false)
    @setUserData category:'condition'

class Or extends LabelRectangle
  NAME: 'or'

  init: (w, h) ->
    super(w, h)
    @label.setText 'OR'

    in1 = new draw2d.InputPort
    in2 = new draw2d.InputPort
    out1 = new draw2d.OutputPort
    @addPort in1
    @addPort in2
    @addPort out1
    @setResizeable(false)
    @setUserData category:'condition'


class Drawer
  modules:
    input:
      button: Button
      text: NewText
      movement: Movement
    output:
      alarm: Bell
      lcd: LCD
      tweet: Tweet
    condition:
      and: And
      or: Or

  constructor: (target="canvas-wrapper") ->
    @canvas = new draw2d.Canvas target
    @canvas.setDimension width:900, height:500

  selectNewElement: (module, type, x=100, y=100) ->
    figure = new @modules[type][module]
    console.debug figure
    @canvas.addFigure figure, x, y

  save: ->
    writer = new draw2d.io.json.Writer
    writer.marshal @canvas, (objs) ->
      console.log objs

      nodes = []
      cache = {}

      for obj in objs
        if obj.type is 'draw2d.Connection'
          outgoing = cache[obj.source.node]
          incoming = cache[obj.target.node]
          outgoing.out.push obj.target.node
          incoming.in.push obj.source.node
        else
          item = {}
          item.in = []
          item.out = []
          item.module = obj.type
          item.id = obj.id
          item.category = obj.userData?.category
          nodes.push item
          cache[item.id] = item

      result =
        nodes: nodes

      result = $http(method: 'POST', url: 'api/schematic', data:result)
      result.success (data, status, headers, conf) ->
          alert('Save successful')
      result.error (data, status, headers, conf) ->
          alert('Save failed')

  restore: (json) ->
    reader = new draw2d.io.json.Reader()
    reader.unmarshal @canvas, json


angular.module('actionReactionApp')
  .controller 'MainCtrl', ($scope, $http) ->
    $scope.drawer = new Drawer
    $scope.presets=
      ButtonToAlarm: '[{"type":"Button","id":"9a86dcdb-9710-eaa4-8e42-766e8958935d","x":100,"y":100,"width":30,"height":30,"userData":{"category":"action"},"cssClass":"Button","bgColor":"none","color":"#1B1B1B","stroke":0,"alpha":1,"radius":2},{"type":"bell","id":"214f8d9d-3cc6-1882-6834-ee897df636b8","x":545,"y":158,"width":30,"height":30,"userData":{"category":"reaction"},"cssClass":"bell","bgColor":"none","color":"#1B1B1B","stroke":0,"alpha":1,"radius":2},{"type":"draw2d.Connection","id":"3133db9e-1695-1eb1-be5d-f4cb42fe187f","userData":{},"cssClass":"draw2d_Connection","stroke":1,"color":"#1B1B1B","outlineStroke":0,"outlineColor":"none","policy":"draw2d.policy.line.LineSelectionFeedbackPolicy","router":"draw2d.layout.connection.ManhattanConnectionRouter","radius":2,"source":{"node":"9a86dcdb-9710-eaa4-8e42-766e8958935d","port":null},"target":{"node":"214f8d9d-3cc6-1882-6834-ee897df636b8","port":null}}]'
    window.$http = $http
    $scope.drawer.selectNewElement 'button', 'input', -100, -100



