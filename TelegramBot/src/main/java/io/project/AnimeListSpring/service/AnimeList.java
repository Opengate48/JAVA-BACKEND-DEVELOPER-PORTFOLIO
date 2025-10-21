package io.project.AnimeListSpring.service;

import io.project.AnimeListSpring.config.BotConfig;
import io.project.AnimeListSpring.model.User;
import io.project.AnimeListSpring.model.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.ResourceUtils;
import org.telegram.telegrambots.bots.TelegramLongPollingBot;
import org.telegram.telegrambots.meta.api.methods.commands.SetMyCommands;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.methods.send.SendPhoto;
import org.telegram.telegrambots.meta.api.objects.InputFile;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.api.objects.commands.BotCommand;
import org.telegram.telegrambots.meta.api.objects.commands.scope.BotCommandScopeDefault;
import org.telegram.telegrambots.meta.api.objects.replykeyboard.InlineKeyboardMarkup;
import org.telegram.telegrambots.meta.api.objects.replykeyboard.buttons.InlineKeyboardButton;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@Component
public class AnimeList extends TelegramLongPollingBot {

    @Autowired
    private UserRepository userRepository;
    final BotConfig botConfig;
    public AnimeList(BotConfig config) {
        this.botConfig = config;
        List<BotCommand> listofCommands = new ArrayList<>();
        listofCommands.add(new BotCommand("/addatitle", "add a new title"));
        listofCommands.add(new BotCommand("/deleteatitle", "delete your title"));
        listofCommands.add(new BotCommand("/displaythelist", "show a list of titles"));
        listofCommands.add(new BotCommand("/totitles", "go to titles"));
        listofCommands.add(new BotCommand("/settheutctimezone", "set up the UTC time zone"));
        listofCommands.add(new BotCommand("/menu", "show the main menu"));

        try {
            this.execute(new SetMyCommands(listofCommands, new BotCommandScopeDefault(), null));
        } catch (TelegramApiException e) {

        }
    }

    @Override
    public String getBotUsername() {
        return botConfig.getBotName();
    }
    @Override
    public String getBotToken() {
        return botConfig.getToken();
    }
    HashMap<Long,Byte> usersstate = new HashMap<>();
    String fileName = "C:\\Users\\makar\\Desktop\\database1.txt";
    String addOngoingCBD = "ADD_ONGOING";
    String delOngoingCBD = "DEL_ONGOING";
    String noCBD = "NO";
    String seriesCBD = "ANIME_SERIES";
    String movieCBD = "ANIME_MOVIE";
    String listCBD = "LIST_OF_TITLES";
    String toTheTitleCBD = "TO_THE_TITLE";
    String utcSettingsCBD = "UTC_SETTINGS";
    String setNameCBD = "SET_NAME";
    String setTimeCBD = "SET_TIME";
    String setTypeCBD = "SET_TYPE";
    String setSeriesCBD = "SET_SERIES";
    String setMovieCBD = "SET_MOVIE";
    String delThisOngoingCBD = "DEL_THIS";
    String setLinkCBD = "SET_LINK";
    private boolean reading = false;


    @Override
    public void onUpdateReceived(Update update) {
        if (update.hasCallbackQuery()){
            String callBackData = update.getCallbackQuery().getData();
            long chatId = update.getCallbackQuery().getMessage().getChatId();
            User usr = userRepository.findById(chatId).get();
            if (callBackData.equals((addOngoingCBD))){
                sendText(chatId, "Write the title name add a new ongoing to your list (title name-yyyy/mm/dd hh:mm):");
                usersstate.put(chatId, (byte)1);

            }
            else if(callBackData.equals(delOngoingCBD)){
                sendText(chatId, "Write the title name:");
                usersstate.put(chatId, (byte)2);
            }
            else if(callBackData.equals(noCBD)) {
                usersstate.remove(chatId);
                sendText(chatId, "Done!");
            }
            else if(usr.hasATitle(callBackData)){
                if (usr.titleHasALink(callBackData)){
                    usr.setLastAddedTitle(callBackData);
                    userRepository.save(usr);
                    InlineKeyboardMarkup inlineKeyboardMarkup = new InlineKeyboardMarkup();
                    List<List<InlineKeyboardButton>> rowsInLine = new ArrayList<>();
                    List<InlineKeyboardButton> rowInLine = new ArrayList<>();
                    var setNameButton = new InlineKeyboardButton();
                    var setTimeButton = new InlineKeyboardButton();
                    var setTypeButton = new InlineKeyboardButton();
                    var linkButton = new InlineKeyboardButton();
                    var setLinkButton = new InlineKeyboardButton();
                    linkButton.setText("Watch!");
                    linkButton.setUrl(usr.getTitleLink(callBackData));
                    rowInLine.add(linkButton);
                    rowsInLine.add(rowInLine);
                    rowInLine = new ArrayList<>();
                    setNameButton.setText("Сhange the name");
                    setNameButton.setCallbackData(setNameCBD);
                    setTimeButton.setText("Change the date");
                    setTimeButton.setCallbackData(setTimeCBD);
                    setTypeButton.setText("Change the type");
                    setTypeButton.setCallbackData(setTypeCBD);
                    setLinkButton.setText("Edit/add a link");
                    setLinkButton.setCallbackData(setLinkCBD);
                    inlineKeyboardMarkup.setKeyboard(rowsInLine);
                    rowInLine.add(setNameButton);
                    rowInLine.add(setTimeButton);
                    rowInLine.add(setTypeButton);
                    rowInLine.add(setLinkButton);
                    rowsInLine.add(rowInLine);
                    rowInLine = new ArrayList<>();
                    var delButton = new InlineKeyboardButton();
                    delButton.setText("Delete a title");
                    delButton.setCallbackData(delThisOngoingCBD);
                    rowInLine.add(delButton);
                    rowsInLine.add(rowInLine);
                    sendTextWithButtons(chatId, usr.getATitle(callBackData), inlineKeyboardMarkup);
                }
                else {
                    usr.setLastAddedTitle(callBackData);
                    System.out.println(callBackData);
                    userRepository.save(usr);
                    InlineKeyboardMarkup inlineKeyboardMarkup = new InlineKeyboardMarkup();
                    List<List<InlineKeyboardButton>> rowsInLine = new ArrayList<>();
                    List<InlineKeyboardButton> rowInLine = new ArrayList<>();
                    var setNameButton = new InlineKeyboardButton();
                    var setTimeButton = new InlineKeyboardButton();
                    var setTypeButton = new InlineKeyboardButton();
                    var setLinkButton = new InlineKeyboardButton();
                    setNameButton.setText("Сhange the name");
                    setNameButton.setCallbackData(setNameCBD);
                    setTimeButton.setText("Change the date");
                    setTimeButton.setCallbackData(setTimeCBD);
                    setTypeButton.setText("Change the type");
                    setLinkButton.setText("Edit/add a link");
                    setLinkButton.setCallbackData(setLinkCBD);
                    setTypeButton.setCallbackData(setTypeCBD);
                    inlineKeyboardMarkup.setKeyboard(rowsInLine);
                    rowInLine.add(setNameButton);
                    rowInLine.add(setTimeButton);
                    rowInLine.add(setTypeButton);
                    rowInLine.add(setLinkButton);
                    rowsInLine.add(rowInLine);
                    rowInLine = new ArrayList<>();
                    var delButton = new InlineKeyboardButton();
                    delButton.setText("Delete a title");
                    delButton.setCallbackData(delThisOngoingCBD);
                    rowInLine.add(delButton);
                    rowsInLine.add(rowInLine);
                    sendTextWithButtons(chatId, usr.getATitle(callBackData), inlineKeyboardMarkup);
                }
            }
            else if(callBackData.equals(seriesCBD)){
                usr.setTitleType(usr.getLastAddedTitle(),true);
                userRepository.save(usr);
                InlineKeyboardMarkup inlineKeyboardMarkup = new InlineKeyboardMarkup();
                List<List<InlineKeyboardButton>> rowsInLine = new ArrayList<>();
                List<InlineKeyboardButton> rowInLine = new ArrayList<>();
                var noButton = new InlineKeyboardButton();
                noButton.setText("No");
                noButton.setCallbackData(noCBD);
                rowInLine.add(noButton);
                rowsInLine.add(rowInLine);
                inlineKeyboardMarkup.setKeyboard(rowsInLine);
                sendTextWithButtons(chatId, "Do you want to add a link to view?", inlineKeyboardMarkup);
                usersstate.put(chatId,(byte)3);
            }
            else if (callBackData.equals(movieCBD)){
                usr.setTitleType(usr.getLastAddedTitle(),false);
                userRepository.save(usr);
                InlineKeyboardMarkup inlineKeyboardMarkup = new InlineKeyboardMarkup();
                List<List<InlineKeyboardButton>> rowsInLine = new ArrayList<>();
                List<InlineKeyboardButton> rowInLine = new ArrayList<>();
                var noButton = new InlineKeyboardButton();
                noButton.setText("No");
                noButton.setCallbackData(noCBD);
                rowInLine.add(noButton);
                rowsInLine.add(rowInLine);
                inlineKeyboardMarkup.setKeyboard(rowsInLine);
                sendTextWithButtons(chatId, "Do you want to add a link to view?", inlineKeyboardMarkup);
                usersstate.put(chatId,(byte)3);
            }
            else if (callBackData.equals(listCBD)){
                InlineKeyboardMarkup inlineKeyboardMarkup = new InlineKeyboardMarkup();
                List<List<InlineKeyboardButton>> rowsInLine = new ArrayList<>();
                List<InlineKeyboardButton> rowInLine = new ArrayList<>();
                var addButton = new InlineKeyboardButton();
                var delButton = new InlineKeyboardButton();
                addButton.setText("Add a new title");
                addButton.setCallbackData(addOngoingCBD);
                delButton.setText("Delete a title");
                delButton.setCallbackData(delOngoingCBD);
                rowInLine.add(addButton);
                rowInLine.add(delButton);
                rowsInLine.add(rowInLine);
                inlineKeyboardMarkup.setKeyboard(rowsInLine);
                sendTextWithButtons(chatId, usr.getAList(), inlineKeyboardMarkup);
            }
            else if (callBackData.equals(toTheTitleCBD)){
                sendTextWithButtons(chatId,"Your titles:", usr.getAListWithButtons());
            }
            else if (callBackData.equals(utcSettingsCBD)){
                sendText(chatId, "Set the UTC time zone that you will use to set the release dates of the titles (from -11 to +12):");
                usersstate.put(chatId,(byte)4);
            }
            else if (callBackData.equals(setNameCBD)){
                sendText(chatId,"Set a new tile name");
                usersstate.put(chatId,(byte)5);
            }
            else if (callBackData.equals(setTimeCBD)){
                sendText(chatId,"Set a new release date for the title");
                usersstate.put(chatId,(byte)6);
            }
            else if (callBackData.equals(setTypeCBD)){
                InlineKeyboardMarkup inlineKeyboardMarkup = new InlineKeyboardMarkup();
                List<List<InlineKeyboardButton>> rowsInLine = new ArrayList<>();
                List<InlineKeyboardButton> rowInLine = new ArrayList<>();
                var serButton = new InlineKeyboardButton();
                var movButton = new InlineKeyboardButton();
                serButton.setText("Anime series");
                serButton.setCallbackData(setSeriesCBD);
                movButton.setText("Anime movie");
                movButton.setCallbackData(setMovieCBD);
                rowInLine.add(serButton);
                rowInLine.add(movButton);
                rowsInLine.add(rowInLine);
                inlineKeyboardMarkup.setKeyboard(rowsInLine);
                sendTextWithButtons(chatId, "Set up a new type of title", inlineKeyboardMarkup);
            }
            else if(callBackData.equals(setSeriesCBD)){
                usr.setTitleType(usr.getLastAddedTitle(),true);
                userRepository.save(usr);
                sendText(chatId,"Done!");
            }
            else if(callBackData.equals(setMovieCBD)){
                usr.setTitleType(usr.getLastAddedTitle(),false);
                userRepository.save(usr);
                sendText(chatId,"Done!");
            } else if (callBackData.equals(delThisOngoingCBD)) {
                usr.delOngoing(usr.getLastAddedTitle());
                userRepository.save(usr);
                sendText(chatId,"Done!");
            }
            else if (callBackData.equals(setLinkCBD)){
                sendText(chatId,"Enter your link:");
                usersstate.put(chatId,(byte)7);
            }
            return;
        }
        var msg = update.getMessage();
        var user = msg.getFrom();
        var id = user.getId();
        if (usersstate.containsKey(id)){
            if (usersstate.get(id) == 1){
                User usr = userRepository.findById(id).get();
                boolean success = usr.addTitle(msg.getText());
                if(success) {
                    userRepository.save(usr);
                    InlineKeyboardMarkup inlineKeyboardMarkup = new InlineKeyboardMarkup();
                    List<List<InlineKeyboardButton>> rowsInLine = new ArrayList<>();
                    List<InlineKeyboardButton> rowInLine = new ArrayList<>();
                    var seriesButton = new InlineKeyboardButton();
                    seriesButton.setText("Anime series");
                    seriesButton.setCallbackData(seriesCBD);
                    var movieButton = new InlineKeyboardButton();
                    movieButton.setText("Anime movie");
                    movieButton.setCallbackData(movieCBD);
                    rowInLine.add(seriesButton);
                    rowInLine.add(movieButton);
                    rowsInLine.add(rowInLine);
                    inlineKeyboardMarkup.setKeyboard(rowsInLine);
                    sendTextWithButtons(id, "Select the type of title:", inlineKeyboardMarkup);
                    usersstate.remove(id);
                }
                else{
                    usersstate.remove(id);
                    sendText(id, "Something went wrong. You may have already added a title with that name. Check out the template.");
                }
            }
            else if (usersstate.get(id) == 2){
                User usr = userRepository.findById(id).get();
                boolean success = usr.delOngoing(msg.getText());
                if(success) {
                    userRepository.save(usr);
                    sendText(id,"Done!");
                }
                else{
                    sendText(id, "There is no such title in your list!");
                }
                usersstate.remove(id);
            }
            else if (usersstate.get(id) == 3){
                User usr = userRepository.findById(id).get();
                usr.setTitleLink(usr.getLastAddedTitle(),msg.getText());
                userRepository.save(usr);
                usersstate.remove(id);
                sendText(id,"Done!");
            }
            else if (usersstate.get(id) == 4){
                int userUTC = Integer.parseInt(msg.getText());
                if (userUTC > 12 || userUTC < -11){
                    sendText(id,"Invalid value, try again");
                }
                else{
                    User usr = userRepository.findById(id).get();
                    usr.setUtc(userUTC);
                    userRepository.save(usr);
                    usersstate.remove(id);
                    sendText(id, "Done!");
                }
            }
            else if (usersstate.get(id)==5){
                User usr = userRepository.findById(id).get();
                usr.setTitleName(usr.getLastAddedTitle(),msg.getText());
                userRepository.save(usr);
                sendText(id,"Done!");
                usersstate.remove(id);
            }
            else if (usersstate.get(id)==6){
                User usr = userRepository.findById(id).get();
                boolean success = usr.setTitleDate(usr.getLastAddedTitle(),msg.getText());
                if (success) {
                    userRepository.save(usr);
                    sendText(id, "Done!");
                }
                else{
                    sendText(id, "Something went wrong.");
                }
                usersstate.remove(id);
            }
            else if (usersstate.get(id)==7){
                User usr = userRepository.findById(id).get();
                usr.setTitleLink(usr.getLastAddedTitle(),msg.getText());
                userRepository.save(usr);
                sendText(id,"Done!");
            }
            return;
        }
        else if (msg.isCommand()) {
            if (msg.getText().equals("/start")) {
                if (userRepository.findById(id).isEmpty()) {
                    User usr = new User();
                    usr.setId(id);
                    userRepository.save(usr);
                    sendText(id, "Set the UTC time zone that you will use to set the release dates of the titles (from -11 to +12):");
                    usersstate.put(id,(byte)4);
                }
                else{
                    sendText(id, "You have already started!");
                }
            } else if (msg.getText().equals("/addatitle")) {
                sendText(id, "Write the title name add a new ongoing to your list (title name-yyyy/mm/dd hh:mm):");
                usersstate.put(id, (byte)1);
            }
            else if (msg.getText().equals("/displaythelist")) {
                InlineKeyboardMarkup inlineKeyboardMarkup = new InlineKeyboardMarkup();
                List<List<InlineKeyboardButton>> rowsInLine = new ArrayList<>();
                List<InlineKeyboardButton> rowInLine = new ArrayList<>();
                var addButton = new InlineKeyboardButton();
                var delButton = new InlineKeyboardButton();
                addButton.setText("add a new title");
                addButton.setCallbackData(addOngoingCBD);
                delButton.setText("delete a title");
                delButton.setCallbackData(delOngoingCBD);
                rowInLine.add(addButton);
                rowInLine.add(delButton);
                rowsInLine.add(rowInLine);
                inlineKeyboardMarkup.setKeyboard(rowsInLine);
                User usr = userRepository.findById(id).get();
                sendTextWithButtons(id, usr.getAList(), inlineKeyboardMarkup);
            }
            else if (msg.getText().equals("/deleteatitle")){
                sendText(id, "Write the title name:");
                usersstate.put(id, (byte)2);
            }
            else if (msg.getText().equals("/totitles")){
                User usr = userRepository.findById(id).get();
                sendTextWithButtons(id,"Your titles:", usr.getAListWithButtons());
            }
            else if (msg.getText().equals("/settheutctimezone")){
                User usr = userRepository.findById(id).get();
                sendText(id, "Your current UTC is  " + usr.getUtc() + ". Set the UTC time zone that you will use to set the release dates of the titles (from -11 to +12):");
                usersstate.put(id,(byte)4);
            }
            else if (msg.getText().equals("/menu")){
                try {
                    sendMenu(id);
                } catch (TelegramApiException e) {
                    throw new RuntimeException(e);
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }
            else{
                sendText(id,"Invalid request. Check out the list of commands.");
            }
            return;
        }

    }
    public void sendMenu(long chatId) throws TelegramApiException, IOException {
        File file = ResourceUtils.getFile("C:\\Users\\makar\\Pictures\\Saved Pictures\\anime_escapizm.jpg");
        InputFile image = new InputFile();
        image.setMedia(file);
        SendPhoto sendPhoto = new SendPhoto();
        sendPhoto.setPhoto(image);
        sendPhoto.setChatId(String.valueOf(chatId));
        InlineKeyboardMarkup inlineKeyboardMarkup = new InlineKeyboardMarkup();
        List<List<InlineKeyboardButton>> rowsInLine = new ArrayList<>();
        List<InlineKeyboardButton> rowInLine = new ArrayList<>();
        var titleListButton = new InlineKeyboardButton();
        var titlesButton = new InlineKeyboardButton();
        var utcSettingsButton = new InlineKeyboardButton();
        titleListButton.setText("List of titles");
        titleListButton.setCallbackData(listCBD);
        titlesButton.setText("To the title");
        titlesButton.setCallbackData(toTheTitleCBD);
        utcSettingsButton.setText("UTC settings");
        utcSettingsButton.setCallbackData(utcSettingsCBD);
        rowInLine.add(titleListButton);
        rowInLine.add(titlesButton);
        rowInLine.add(utcSettingsButton);
        rowsInLine.add(rowInLine);
        rowInLine = new ArrayList<>();
        var addButton = new InlineKeyboardButton();
        var delButton = new InlineKeyboardButton();
        addButton.setText("Add a new title");
        addButton.setCallbackData(addOngoingCBD);
        delButton.setText("Delete a title");
        delButton.setCallbackData(delOngoingCBD);
        rowInLine.add(addButton);
        rowInLine.add(delButton);
        rowsInLine.add(rowInLine);
        inlineKeyboardMarkup.setKeyboard(rowsInLine);
        sendPhoto.setReplyMarkup(inlineKeyboardMarkup);
        try {
            execute(sendPhoto);                      //Actually sending the message
        } catch (TelegramApiException e) {
            throw new RuntimeException(e);      //Any error will be printed here
        }
    }
    public void sendTextWithButtons(Long who, String what, InlineKeyboardMarkup inlineKeyboardMarkup){
        SendMessage sm = SendMessage.builder()
                .chatId(who.toString()) //Who are we sending a message to
                .text(what).build();    //Message content
        sm.setReplyMarkup(inlineKeyboardMarkup);

        try {
            execute(sm);                        //Actually sending the message
        } catch (TelegramApiException e) {
            throw new RuntimeException(e);      //Any error will be printed here
        }
    }
    public void sendText(Long who, String what){
        SendMessage sm = SendMessage.builder()
                .chatId(who.toString()) //Who are we sending a message to
                .text(what).build();    //Message content
        try {
            execute(sm);                        //Actually sending the message
        } catch (TelegramApiException e) {
            throw new RuntimeException(e);      //Any error will be printed here
        }
    }
}
