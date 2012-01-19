App = window.App
BaseView = App.Views.Base

class Table extends BaseView
  el: $("#current_table")
  tmpl: "partials/blackjack/table"
  
  partials: {
    card: "blackjack-card"
  }
  constructor: () ->
    # @hands = {}
    @prev_table = {}
    @table = {}
  
  _card_value: (index) ->
    throw "can't run _card_value on Ace" if index == 0
    throw "can't run _card_value on card higher than max" if index > 13 # TODO: use CardFactory/Deck
    return 10 if index > 9
    return index + 1
  
  _hand_value: (hand) ->
    # hand ranks are zero-indexed: Ace = 0
    value = 0
    for card in hand
      if card.r != 0 
        value += App.Views.Table._card_value(card.r)
      else
        # Handle Ace case
        if value + 11 > 21
          value += 1
        else
          value += 11
    return value
  on_update: (err, data) ->
    console.log("error Table.on_update") if err
    
    console.log(["Table.on_update: ", data.action, err, data])
    
    # cache important data.state
    if data.state?
      App.Views.Table.prev_table = App.Views.Table.table
      if data.state.table?
        App.Views.Table.table = _.clone(data.state.table)
      if data.state.hands?
        App.Views.Table.table.hands = _.clone(data.state.hands)
      if data.state.card?
        newcard = _.clone(data.state.card)
        console.log("newcard = ")
        console.log(newcard)
        console.log(data.actor)
        App.Views.Table.table.hands[data.actor].push(newcard)
    
    # console.log("[Activity]: " + [data.actor, data.verb, data.target].join(" "))
    switch data.action
      when "start"
        App.Views.Table.startGame(data)
      when "joined"
        App.Views.Table.ohai_player(data)
      when "left"
        App.Views.Table.bye_player(data)
      when "has turn"
      #   App.Views.Table.prompt_deal(data)
        console.log("has turn: " + JSON.stringify(data))
        App.Views.Table.notify(data.action)
      when "new card"
        console.log("new card!")
        # App.Views.Table.log(data)
        App.Views.Table.updateHand(data)
      when "hand over"
        App.Views.Table.finish(data)
        App.Views.Table.notify(data.action)
        
        username = App.Views.Table.username 
        bet = data.state.table.players[username].bet
        console.log("bet = " + bet)
        your_hand = App.Views.Table._hand_value(App.Views.Table.prev_table.hands[username])
        dealer_hand = App.Views.Table._hand_value(App.Views.Table.prev_table.hands["dealer"])
        verb = data.state.table.players[username].outcome
        prefix = "+"
        prefix = "-" if verb == "lost"
        App.Views.Table.log({
          actor: "You",
          verb: verb,
          object: "#{your_hand} to #{dealer_hand} (#{prefix}" + bet + ").  Try again: Press D"
        })
        App.Routers.Actions.open()
      when "broke"
        App.Views.Table.updatePurse(data.purse)
        App.Views.Table.log({
          actor: "The casino",
          verb: "bails",
          object: "you out (+500)"
        })
      else 
        console.log(["Table.on_update: ", data.action, err, data])
  
  log: (activity) ->
    $('#gamelog h4').insertAfter("<p>" + [activity.actor, activity.verb, activity.object].join(" ") + ".</p>")
  
  notify_active: false
  notify: (type = "turn") ->
    # console.log("notified #{type} & active? #{@notify_active.toString()}")
    if not App.Views.Table.usernamenotify_active
      App.Views.Table.usernamenotify_active = true
      
      switch type
        when "turn"
          App.Routers.Actions.open()
          console.log("notify of type turn for " + App.Views.Table.username)
          $('#' + App.Views.Table.username + " .username p").addClass("turn")
        when "hand over"
          App.Routers.Actions.open()
          App.Views.Table.log({
            actor: "You",
            verb: "should",
            object: "push deal (D)"
          })
        else 
          console.log("notify of type #{type} for " + App.Views.Table.username)
          App.Routers.Actions.open()
          # TODO: 
  
  denotify: () ->
    App.Views.Table.username.notify_active = false
    $('#' +App.Views.Table.username + " .username p").removeClass("turn")
  
  process: (table_name, callback) ->
    self = this
    now.sit_down(table_name, @on_update, (err, table) ->
      console.log("inside sit_down's callback")
      if err == "Table is full"
        err = null
        App.Views.Lobby.rm()
        table = App.Views.Table.table
      
      throw err if err

      # Automatically set a bet TODO: switch to a diff mode?
      now.bet(100, (err, amount) ->
        console.log("set a bet")
        console.log(arguments)
        window.App.Views.Table.username = username = now.player.username
        console.log("bet set by #{username}")
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
  
  finish: (data) ->
    @updatePurse()
    console.log("tell user to deal!")
  
  startGame: (data) ->
    console.log("startGame")
    console.log(data)
    
    # Clear out old cards:
    $('#dealer-box .hand').empty()
    $('#' + @username + " .hand").empty()
    console.log("parsing dealer's hand")
    dealer_hand = @parseHand(@table.hands["dealer"])
    dealer_output = App.Partials[@partials["card"]].render(dealer_hand)
    console.log("dealer_output: ")
    console.log(dealer_output)
    $('#dealer-box .hand').append(dealer_output)
    username = @username
    console.log("parsing #{username}'s hand")
    console.log(@table.hands[@username])
    player_hand = @parseHand(@table.hands[@username])
    player_output = App.Partials[@partials["card"]].render(player_hand)
    $('#' + @username + " .hand").append(player_output)
    console.log("startGame over")
  
  updateHand: (data) ->
    username = data.actor
    # newcard = @parseHand(data.state.card)
    console.log("update hand called by #{username}? #{username==App.Views.Table.username}")
    # console.log(data)
    # console.log(newcard)
    newcard = @parseHand(App.Views.Table.table.hands[username].slice(-1))
    # console.log(newcard)  
    switch username
      when "dealer"
        ele = $('#dealer-box .hand')
      when App.Views.Table.username
        uname = App.Views.Table.username
        console.log("updating hand for #{uname}")
        ele = $('#' + App.Views.Table.username + " .hand")
      else
        console.log("unknown username: #{username}")
        return null
    # output = App.Partials[@partials["card"]].render(newcard)
    output = App.Partials[@partials["card"]].render(newcard)
    console.log(output)
    ele.append(output)
  
  prompt_deal: (data) ->
    console.log("prompt_deal: " + JSON.stringify(data))
    if @table.players[@username].outcome
      console.log("outcome = #{@table.players[@username].outcome}")
  
  ranks: ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
  suits: ["S", "C", "D", "H"]
  parseHand: (hand) ->
    shorthands = []
    for card in hand
      sh = @ranks[card.r] + @suits[card.s]
      shorthands.push({id: sh})
    console.log("shorthands")
    console.log(shorthands)
    return {cards: shorthands}
  
  hitHandler: (e) ->
    e.preventDefault()
    now.hit()
    App.Views.Table.denotify()
    console.log("hit clicked")
    return false
  
  standHandler: (e) ->
    e.preventDefault()
    now.stand()
    App.Views.Table.denotify()
    console.log("stand clicked")
    return false
  
  dealHandler: (e) ->
    e.preventDefault()
    now.deal()
    App.Views.Table.denotify()
    console.log("stand clicked")
    return false
  
  updatePurse: (bank = null) ->
    bank = @table.players[@username].purse if bank == null
    # rendered_purse = $('#purse_value').text()
    # checkbook = 500
    # checkbook = parseInt(rendered_purse) if _.isNumber(rendered_purse) and not _.isNaN(rendered_purse)
    $('#purse_value').text(bank)
  
  postRender: (table) ->
    console.log("postRender()")
    console.log(table)
    @table = table
    @updatePurse()
    
    now.deal(() ->
      console.log("now.deal() arguments:")
      console.log(arguments)
      console.log("rebinding a.actions_hit")
      
      $("a.actions_hit").unbind('click.Table')
      $("a.actions_hit").bind("click.Table", App.Views.Table.hitHandler)
      $("a.actions_stand").unbind("click.Table")
      $("a.actions_stand").bind("click.Table", App.Views.Table.standHandler)
      $("a.actions_deal").unbind("click.Table")
      $("a.actions_deal").bind("click.Table", App.Views.Table.dealHandler)
    )

App.Views.Table = new Table()