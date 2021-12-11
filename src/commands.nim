import options, telebot, asyncdispatch, strformat, strutils

from auxillary import getTaggedUserByMessage

proc helpMenu*(bot: Telebot, message: Message): Future[void] {.async.} =
    # todo
    discard await bot.sendMessage(
        message.chat.id, 
        "So you need some help?\nHere is the list of commands:"
    )

proc muteMember*(bot: Telebot, message: Message, mute: bool = true): Future[void] {.async.} =
    try:
        let u: Option[User] = getTaggedUserByMessage(message)
        if issome(u):
            let user: User = get(u)
            let q = ChatPermissions(
                canSendMessages: option[bool](not mute),
                canSendMediaMessages: option[bool](not mute),
                canSendPolls: option[bool](not mute),
                canSendOtherMessages: option[bool](not mute),
                canAddWebPagePreviews: option[bool](not mute),
                canChangeInfo: option[bool](not mute),
                canInviteUsers: option[bool](not mute),
                canPinMessages: option[bool](not mute),
            )

            try:
                # restrictChatMember will throw IOError if fail
                let word = if mute: "muted" else: "unmuted"
                discard await bot.restrictChatMember($message.chat.id, user.id, q)
                discard await bot.sendMessage(
                    message.chat.id,
                    &"@{get(user.username)} has been {word}!"
                )
            except IOError:
                discard await bot.sendMessage(
                    message.chat.id,
                    "I am not allowed to do that!"
                )

                return
        else:
            # todo: make below mute user with @username
            #[ let userData = get(message.text).split(' ')
            if userData.len() != 2:
                discard await bot.sendMessage(
                    message.chat.id,
                    "HEY! Don't send anything else, I'm a dumb dumb and can't read the extra text! (user not muted)"
                )
            else:
                let username = userData[len(userData) - 1]
                if not username.startsWith('@'):
                    discard await bot.sendMessage(
                        message.chat.id,
                        "Ya gotta tag someone for me to mute them!"
                    )
                else:
                    discard await bot.sendMessage(
                        message.chat.id,
                        &"{username} is this what was sent?"
                    )

            let msgEntities = get(message.entities)[1]
            if msgEntities.kind == "mention":
                echo get(message.text) ]#

            discard await bot.sendMessage(
                message.chat.id,
                &"Please tag a message to mute user."
            )

            return
    except UnpackDefect:
        discard await bot.sendMessage(
            message.chat.id, 
            "Unpack Defect bro, that option does not exist"
        )

proc makeAdmin*(bot: Telebot, message: Message, giveRole: bool = true): Future[void] {.async.} =
    let u: Option[User] = getTaggedUserByMessage(message)
    if issome(u):
        let user: User = get(u)
        try:
            if giveRole:
                discard await bot.promoteChatMember($message.chat.id, user.id, canManageChat = true, canRestrictMembers = true, canPinMessages = true, canPromoteMembers = true, canDeleteMessages = true, canManageVoiceChats = true, canInviteUsers = true, canChangeInfo = true)

                discard await bot.sendMessage(
                    message.chat.id,
                    &"@{get(user.username)} has been promoted to admin! Be pround you sun of a gun!"
                )
            else:
                # all parameters are false by default
                discard await bot.promoteChatMember($message.chat.id, user.id)

                discard await bot.sendMessage(
                    message.chat.id,
                    &"Aww! @{get(user.username)} has been demoted! Admin privilage removed!"
                )

        except IOError:
            discard await bot.sendMessage(
                message.chat.id,
                "Sorry! I'm not admin, so I lack the power!"
            )
    else:
        discard await bot.sendMessage(
            message.chat.id,
            "Who am I supposed to promote??? Tag someone, buddy."
        )