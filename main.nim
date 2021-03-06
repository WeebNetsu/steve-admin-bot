# todo: muting and unmuting admins causes them to lose admin privilages
# todo: Admins can mute other admins
# todo: you can make an already existing admin an admin

import options, telebot, asyncdispatch, strutils

# my stuff
import src/commands
from src/auxillary import getSecretJson, checkAdmin, checkSameUser, checkIsBot

proc main(bot: Telebot, u: Update): Future[bool] {.async, gcsafe.} =
    if not isSome(u.message): # return true will make bot stop process other callbacks
        return true

    let message = get(u.message)

    try:
        discard await bot.setMyCommands(@[
            BotCommand(command: "/help", description: "Get help"),
            BotCommand(command: "/mute", description: "Mute Member"),
            BotCommand(command: "/unmute", description: "Unmute Member"),
            BotCommand(command: "/makeadmin", description: "Give user Admin role"),
            # BotCommand(command: "/removeadmin", description: "Remove user Admin role"),
            BotCommand(command: "/ping", description: "Ping me to check if I'm online"),
        ])

        let 
            isBot: bool = await checkIsBot(bot, message)
            isAdmin: bool = await checkAdmin(bot, message)
            sameUser: bool = await checkSameUser(bot, message)

        if isSome(message.text):
            let 
                text = get(message.text)
                isAllowed: bool = isAdmin and not (sameUser or isBot)

            var called = true

            if text.startsWith("/help"):
                if isAllowed:
                    await helpMenu(bot, message)
            elif text.startsWith("/ping"):
                if isAllowed:
                    discard await bot.sendMessage(message.chat.id, "Heyo! I am online!")
            elif text.startsWith("/mute"):
                if isAllowed:
                    await muteMember(bot, message)
            elif text.startsWith("/unmute"):
                if isAllowed:
                    await muteMember(bot, message, false)
            elif text.startsWith("/makeadmin"):
                if isAllowed:
                    await makeAdmin(bot, message)
            else:
                called = false

            if called:
                if not isAdmin:
                    discard await bot.sendMessage(message.chat.id, "You are not Admin! Now begone!")
                elif sameUser:
                    discard await bot.sendMessage(message.chat.id, "You shouldn't be playing with your own permissions...")
                elif isBot:
                    discard await bot.sendMessage(message.chat.id, "I am not allowed to mess with bots... Sowwy senpai!")
    except:
        discard await bot.sendMessage(
            message.chat.id,
            "An unknown error occured! Please contact my developer!"
        )

const secret = slurp("secret.json")
let bot = newTeleBot(getSecretJson("api_key", secret))
bot.onUpdate(main)
bot.poll()

#[ # I removed this because it can be too dangerous to keep around
elif text.startsWith("/removeadmin"):
    # todo?: only the channel creator should be able to use this
    # the property exists on the ChatMember object type
    # check checkAdmin()
    if not await checkSameUser(bot, message):
        await makeAdmin(bot, message, false) ]#

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
    entities: Some(@[(
        kind: "bot_command",
        offset: 0,
        length: 5,
        url: None[string],
        user: None[User],
        language: None[string]
    )])
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