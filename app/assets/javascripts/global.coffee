jQuery ->
  displayHint = (strength) ->
    msg = 'Password is ' + strength

    estimate_message = this.next('.estimate-message')
    if estimate_message.length > 0
      estimate_message.text msg
    else
      this.after '<span class="help-block estimate-message">' + msg + '</span>'

  $('form').on 'keyup', '.estimate-password', ->
    $this = $(this)
    estimation = zxcvbn($this.val())

    switch estimation.score
      when 0 then displayHint.call($this, "very weak")
      when 1 then displayHint.call($this, "weak")
      when 2 then displayHint.call($this, "okay")
      when 3 then displayHint.call($this, "strong")
      when 4 then displayHint.call($this, "very strong")

  return