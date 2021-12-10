import options, telebot, asyncdispatch, strformat, json, strutils

import aux

const secret = slurp("secret.json")

proc getSecretJson(key: string): string =
    let jsonSecret = parseJson(secret)

    return jsonSecret[key].getStr()

# --------------------------- COMMANDS ---------------------------
proc helpMenu(bot: Telebot, message: Message): Future[void] {.async.} =
    # todo
    discard await bot.sendMessage(
        message.chat.id, 
        "So you need some help?\nHere is the list of commands:"
    )

proc muteMember(bot: Telebot, message: Message, mute: bool = true): Future[void] {.async.} =
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
            #[ 
                let userData = get(message.text).split(' ')
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
            ]#

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

proc makeAdmin(bot: Telebot, message: Message, giveRole: bool = true): Future[void] {.async.} =
    let u: Option[User] = getTaggedUserByMessage(message)
    if issome(u):
        let user: User = get(u)
        discard await bot.promoteChatMember($message.chat.id, user.id)
        discard await bot.sendMessage(
            message.chat.id,
            &"@{get(user.username)} has been promoted to admin! Be pround you sun of a gun!"
        )
    else:
        discard await bot.sendMessage(
            message.chat.id,
            "Who am I supposed to promote??? Tag someone buddy."
        )
    #[ 
    chat_id
    user_id
    is_anonymous - 
        Pass True, if the administrator's presence in the chat is hidden
    can_manage_chat - 
        Pass True, if the administrator can access the chat event log, chat statistics, message statistics in channels, see channel members, see anonymous administrators in supergroups and ignore slow mode. Implied by any other administrator privilege
    can_post_messages - 
        Pass True, if the administrator can create channel posts, channels only
    can_edit_messages - 
        Pass True, if the administrator can edit messages of other users and can pin messages, channels only
    can_delete_messages - 
        Pass True, if the administrator can delete messages of other users
    can_manage_voice_chats - 
        Pass True, if the administrator can manage voice chats
    can_restrict_members - 
        Pass True, if the administrator can restrict, ban or unban chat members
    can_promote_members - 
        Pass True, if the administrator can add new administrators with a subset of their own privileges or demote administrators that he has promoted, directly or indirectly (promoted by administrators that were appointed by him)
    can_change_info - 
        Pass True, if the administrator can change chat title, photo and other settings
    can_invite_users - 
        Pass True, if the administrator can invite new users to the chat
    can_pin_messages - 
        Pass True, if the administrator can pin messages, supergroups only
 ]#


# --------------------------- BOT ---------------------------
proc main(bot: Telebot, u: Update): Future[bool] {.async, gcsafe.} =
    if not u.message.isSome: # return true will make bot stop process other callbacks
        return true

    let message = get(u.message)

    try:
        discard await bot.setMyCommands(@[
            BotCommand(command: "/help", description: "Get help"),
            BotCommand(command: "/mute", description: "Mute Member"),
            BotCommand(command: "/unmute", description: "Unmute Member"),
            BotCommand(command: "/makeadmin", description: "Give user Admin role"),
            BotCommand(command: "/removeadmin", description: "Remove user Admin role"),
        ])

        if message.text.isSome:
            let text = message.text.get
            if text.startsWith("/help"):
                await helpMenu(bot, message)
            elif text.startsWith("/mute"):
                await muteMember(bot, message)
            elif text.startsWith("/makeadmin"):
                await makeAdmin(bot, message, false)
            # elif text.startsWith("/removeadmin"):
                # await makeAdmin(bot, message, true)
    except:
        discard await bot.sendMessage(
            message.chat.id,
            "An unknown error occured! Please contact my developer!"
        )

let bot = newTeleBot(getSecretJson("api_key"))
bot.onUpdate(main)
bot.poll()


#[ (
    messageId: 6
    fromUser: Some((
        id: 1231231
        isBot: false
        firstName: "Netsu"
        lastName: None[string]
        username: Some("SoupCookie")
        languageCode: Some("en")
        canJoinGroups: None[bool]
        canReadAllGroupMessages: None[bool]
        supportsInlineQueries: None[bool]
    ))
    senderChat: None[Chat]
    date: 1638105649
    chat: (
        id: -647359376
        kind: "group"
        title: Some("test bot group")
        username: None[string]
        firstName: None[string]
        lastName: None[string]
        photo: None[ChatPhoto]
        description: None[string]
        inviteLink: None[string]
        pinnedMessage: ...
        permissions: None[ChatPermissions]
        slowModeDelay: None[int]
        stickerSetName: None[string]
        canSetStickerSet: None[bool]
    )
    forwardFrom: None[User]
    forwardFromChat: None[Chat]
    forwardFromMessageId: None[int]
    forwardSignature: None[string]
    forwardSenderName: None[string]
    forwardDate: None[int]
    replyToMessage: ...
    viaBot: None[User]
    editDate: None[int]
    mediaGroupId: None[string]
    authorSignature: None[string]
    text: Some("/mute")
    entities: Some(@[(kind: "bot_command"
    offset: 0
    length: 5
    url: None[string]
    user: None[User]
    language: None[string])])
    animation: None[Animation]
    audio: None[Audio]
    document: None[Document]
    photo: None[seq[PhotoSize]]
    sticker: None[Sticker]
    video: None[Video]
    videoNote: None[VideoNote]
    voice: None[Voice]
    caption: None[string]
    captionEntities: None[seq[MessageEntity]]
    contact: None[Contact]
    dice: None[Dice]
    game: None[Game]
    poll: None[Poll]
    venue: None[Venue]
    location: None[Location]
    newChatMembers: None[seq[User]]
    leftChatMember: None[User]
    newChatTitle: None[string]
    newChatPhoto: None[seq[PhotoSize]]
    deleteChatPhoto: None[bool]
    groupChatCreated: None[bool]
    superGroupChatCreated: None[bool]
    chanelChatCreated: None[bool]
    messageAutoDeleteTimerChanged: None[MessageAutoDeleteTimerChanged]
    migrateToChatId: None[int64]
    migrateFromChatId: None[int64]
    pinnedMessage: ...
    invoice: None[Invoice]
    successfulPayment: None[SuccessfulPayment]
    connectedWebsite: None[string]
    passportData: None[PassportData]
    proximityAlertTriggered: None[ProximityAlertTriggered]
    voiceChatScheduled: None[VoiceChatScheduled]
    voiceChatStarted: None[VoiceChatStarted]
    voiceChatEnded: None[VoiceChatEnded]
    voiceChatParticipantsInvited: None[VoiceChatParticipantsInvited]
    replyMarkup: None[InlineKeyboardMarkup]
) ]#