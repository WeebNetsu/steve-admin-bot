import telebot, options

func getTaggedUserByMessage*(message: Message): Option[User] =
    let u = message.replyToMessage
    if issome(u):
        return some(get(get(u).fromUser))
    else:
        return none(User)