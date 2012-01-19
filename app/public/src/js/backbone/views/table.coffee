App = window.App
BaseView = App.Views.Base

class Table extends BaseView
  el: $("#current_table")
  tmpl: "partials/blackjack/table"

  partials: {
    card: "blackjack-card"
  }
  constructor: () ->
    @hands = {}
    @table = {}

  on_update: (err, data) ->
    console.log("error Table.on_update") if err

    # cache important data.state
    if data.state?
      if data.state.table?
        window.App.Views.Table.table = _.clone(data.state.table)
      if data.state.hands?
        window.App.Views.Table.hands = _.clone(data.state.hands)
      if data.state.card?
        window.App.Views.Table.hands[data.actor].push(data.state.card)

    # console.log("[Activity]: " + [data.actor, data.verb, data.target].join(" "))
    switch data.action
      when "start"
        window.App.Views.Table.updateHands(data)
      when "joined"
        window.App.Views.Table.ohai_player(data)
      when "left"
        window.App.Views.Table.bye_player(data)
      when "has turn"
        window.App.Views.Table.prompt_deal(data)
      when "new card"
        window.App.Views.Table.updateHand(data)
      else 
        # body...
        console.log(["Table.on_update: ", err, data])
  
  process: (table_name, callback) ->
    self = this
    now.sit_down(table_name, @on_update, (err, table) ->
      console.log("inside sit_down's callback")
      throw err if err

      # Automatically set a bet TODO: switch to a diff mode?
      now.bet(100, (err, amount) ->
        console.log("set a bet")
        console.log(arguments)
        window.App.Views.Table.username = username = now.player.username
        player = {
          username: username,
          purse: table.players[username].purse
        }
        players = table.seats.filter((d) ->
          if d == 'shy-fog-62' #username
            player = table.players[d]
            return false
          else
            return true
        )
        emptycount = table.meta.max_players - table.seats.length
        emptyseats = if emptycount > 0 then [1..emptycount].map((d) -> {id: d}) else []
        ctx = {}
        ctx.table = {}
        ctx.table.player = player
        ctx.table.players = players
        ctx.table.emptyseats = emptyseats

        # TODO: remove debugging statements
        window.ctx = ctx
        window.tmpl = App.Templates[App.Views.Table.tmpl]

        callback(null, table, ctx)
      )
    )

  render: (table_name) ->
    self = this
    this.process(table_name, (err, table, context) ->
      self.el.hide()
        .html(self.template(context))
        .slideDown()
        self.delegateEvents()
      self.postRender(table)
    )
    return this

  ## Listener Callbacks
  emptyseats: []
  ohai_player: (data) ->
    if data.actor != @username
      s = $(".emptyseats").slice(-1).fadeOut()
      @emptyseats.push(s)
      $(".players-boxes").prepend(App.Templates["partials/blackjack/players"].render({username: data.actor})).hide().fadeIn()

  bye_player: (data) ->
    $('.players-boxes #' + data.actor).fadeOut()
    s = @emptyseats.shift().append(".players-boxes").hide().fadeIn()

  updateHands: (data) ->
    console.log("updateHands")
    console.log(data)
    dealer_hand = @parseHand(@hands["dealer"])
    $('#dealer-box .hand').append(App.Partials[@partials["card"]].render(dealer_hand))

    player_hand = @parseHand(@hands[@username])
    $('#' + @username + " .hand").append(App.Partials[@partials["card"]].render(player_hand))

  updateHand: (data) ->
    username = data.actor
    newcard = @parseHand(data.state.card)

    switch username
      when "dealer"
        ele = $('#dealer-box .hand')
      when App.Views.Table.username
        ele = $('#' + @username + " .hand")
      else
        # TODO: 
        return null
    
    ele.append(App.Partials[@partials["card"]].render(newcard))
    
    

  prompt_deal: (data) ->

  
  ranks: ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
  suits: ["S", "C", "D", "H"]
  parseHand: (hand) ->
    shorthands = []
    for card in hand
      sh = @ranks[card.r] + @suits[card.s]
      shorthands.push({id: sh})
    return {cards: shorthands}

  hitHandler: (e) ->
    e.preventDefault()
    now.hit()
    console.log("hit clicked")
    return false
  
  standHandler: (e) ->
    e.preventDefault()
    now.stand()
    console.log("stand clicked")
    return false
  
  postRender: (table) ->
    console.log("postRender()")
    console.log(table)
    now.deal(() ->
      console.log("now.deal() arguments:")
      console.log(arguments)
      console.log("rebinding a.actions_hit")

      $("a.actions_hit").unbind('click.Table')
      $("a.actions_hit").bind("click.Table", App.Views.Table.hitHandler)
    )

App.Views.Table = new Table()