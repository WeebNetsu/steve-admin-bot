import telebot, options, json, asyncdispatch

func getTaggedUserByMessage*(message: Message): Option[User] =
    let u = message.replyToMessage
    if issome(u):
        return some(get(get(u).fromUser))
    else:
        return none(User)

proc getSecretJson*(key: string, secret: string): string =
    let jsonSecret = parseJson(secret)

    return jsonSecret[key].getStr()

proc checkAdmin*(bot: Telebot, message: Message): Future[bool] {.async.} =
    let admins: seq[ChatMember] = await bot.getChatAdministrators($message.chat.id)

    let messageOwner = message.fromUser
    if isSome(messageOwner):
        for admin in admins:
            if (get(messageOwner).id == admin.user.id) and (not admin.user.isBot):
                return true

    return false

proc checkSameUser*(bot: Telebot, message: Message): Future[bool] {. async .} =
    result = false
    let messageOwner = message.fromUser
    let taggedMessageUser = getTaggedUserByMessage(message)

    if isSome(messageOwner) and isSome(taggedMessageUser):
        if get(messageOwner).id == get(taggedMessageUser).id:
            discard await bot.sendMessage(
                message.chat.id,
                "You shouldn't be playing with your own permissions..."
            )
            result = true