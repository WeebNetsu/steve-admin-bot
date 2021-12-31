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
    let 
        admins: seq[ChatMember] = await bot.getChatAdministrators($message.chat.id)
        messageOwner = message.fromUser

    if isSome(messageOwner):
        for admin in admins:
            if (get(messageOwner).id == admin.user.id) and (not admin.user.isBot):
                return true

    return false

proc checkSameUser*(bot: Telebot, message: Message): Future[bool] {. async .} =
    result = false
    let 
        messageOwner: Option[User] = message.fromUser
        taggedMessageUser: Option[User] = getTaggedUserByMessage(message)

    if isSome(messageOwner) and isSome(taggedMessageUser):
        if get(messageOwner).id == get(taggedMessageUser).id:
            result = true

proc checkIsBot*(bot: Telebot, message: Message): Future[bool] {. async .} =
    result = false
    let taggedMessageUser: Option[User] = getTaggedUserByMessage(message)

    if isSome(taggedMessageUser):
        result = get(taggedMessageUser).isBot
