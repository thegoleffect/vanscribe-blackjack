now.sit_down("Table 0")
now.bet(100, function(){ console.log(arguments); })
now.deal(function(){ console.log(arguments); })

now.hit()

now.test_poke(function(){ util.debug(arguments); })