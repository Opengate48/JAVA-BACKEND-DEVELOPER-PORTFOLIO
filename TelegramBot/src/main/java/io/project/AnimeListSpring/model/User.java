package io.project.AnimeListSpring.model;

import io.project.AnimeListSpring.service.DeltaDate;
import jakarta.persistence.*;
import org.telegram.telegrambots.meta.api.objects.replykeyboard.InlineKeyboardMarkup;
import org.telegram.telegrambots.meta.api.objects.replykeyboard.buttons.InlineKeyboardButton;

import java.util.*;

@Entity
@Table(name="users")
public class User {
    @Id
    private Long id;          //primary key

    @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id")
    private Map<String, Title> titles = new TreeMap<>();
    private String lastAddedTitle;
    private Integer utc;

    public void setUtc(Integer utc) {
        this.utc = utc;
    }

    public Integer getUtc() {
        return utc;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }
    public boolean hasATitle(String titleName){
        if(this.titles.containsKey(titleName)){
            return true;
        }
        else{
            return false;
        }
    }
    public boolean titleHasALink(String titleName){
        if(this.titles.containsKey(titleName)){
            if(this.titles.get(titleName).isHasALink()){
                return true;
            }
            else{
                return false;
            }
        }
        else{
            return false;
        }
    }
    public String getLastAddedTitle() {
        return lastAddedTitle;
    }
    public void setLastAddedTitle(String lastAddedTitle) {
        this.lastAddedTitle = lastAddedTitle;
    }
    public void setTitleLink(String titleName, String link){
        Title newTitle = this.titles.get(titleName);
        newTitle.setLink(link);
        this.titles.put(newTitle.getName(), newTitle);
    }
    public void setTitleType(String titleName, boolean type){
        Title newTitle = this.titles.get(titleName);
        newTitle.setType(type);
        this.titles.put(newTitle.getName(), newTitle);
    }
    public void setTitleName(String oldTitleName, String newTitleName){
        Title title = this.titles.get(oldTitleName);
        title.setName(newTitleName);
        this.titles.put(title.getName(), title);
    }
    public boolean setTitleDate(String titleName, String newDate){
        Title title = this.titles.get(titleName);
        Short[] date = {Short.parseShort(newDate.substring(0,4)), (short) (Short.parseShort(newDate.substring(5,7))-1),Short.parseShort(newDate.substring(8,10)),Short.parseShort(newDate.substring(11,13)),Short.parseShort(newDate.substring(14,16))};
        if (date[1]>11 || date[1] < 0){
            return false;
        }
        int[] daysInMoth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
        if (date[1] == 1) {
            if (date[0] % 4 == 0) {
                if (date[2] > 29 || date[2] < 1) {
                    return false;
                }
            } else {
                if (date[2] > 28 || date[2] < 1) {
                    return false;
                }
            }
        }
        else{
            if (date[2] > daysInMoth[Integer.valueOf(date[1])] || date[2] < 1){
                return false;
            }
        }
        if (date[3] > 23 || date[3] < 0){
            return false;
        }
        if (date[3] > 59 || date[3] < 0){
            return false;
        }
        title.setReleaseTime(date);
        this.titles.put(title.getName(), title);
        return  true;
    }
    public String getTitleLink(String titleName){
        Title title = this.titles.get(titleName);
        return title.getLink();
    }
    public boolean delOngoing(String titleName) {

        if (this.titles.containsKey(titleName)) {
            this.titles.remove(titleName);
            return true;
        }
        else{
            return false;
        }
    }

    public boolean addTitle(String titleConfig) {
        String[] strings = titleConfig.split("-");
        this.lastAddedTitle = strings[0];
        if (strings.length != 2){
            return false;
        }
        if (!this.titles.containsKey(strings[0])) {
            Title newTitle = new Title();
            Short[] releaseTime = new Short[5];

            releaseTime[0] = Short.parseShort(strings[1].substring(0, 4));

            releaseTime[1] = (short) (Short.parseShort(strings[1].substring(5, 7)) - 1);
            releaseTime[2] = Short.parseShort(strings[1].substring(8, 10));
            releaseTime[3] = Short.parseShort(strings[1].substring(11, 13));
            releaseTime[4] = Short.parseShort(strings[1].substring(14, 16));
            if (releaseTime[1]>11 || releaseTime[1] < 0){
                return false;
            }
            int[] daysInMoth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
            if (releaseTime[1] == 1) {
                if (releaseTime[0] % 4 == 0) {
                    if (releaseTime[2] > 29 || releaseTime[2] < 1) {
                        return false;
                    }
                } else {
                    if (releaseTime[2] > 28 || releaseTime[2] < 1) {
                        return false;
                    }
                }
            }
            else{
                if (releaseTime[2] > daysInMoth[Integer.valueOf(releaseTime[1])] || releaseTime[2] < 1){
                    return false;
                }
            }
            if (releaseTime[3] > 23 || releaseTime[3] < 0){
                return false;
            }
            if (releaseTime[3] > 59 || releaseTime[3] < 0){
                return false;
            }
            /*
            try{
                Calendar date = Calendar.getInstance();
                date.set(releaseTime[0],releaseTime[1],releaseTime[2],releaseTime[3],releaseTime[4]);
            }catch (){

            }
            */

            newTitle.setName(strings[0]);
            //title.add(strings[0]);
            newTitle.setReleaseTime(releaseTime);
            ///title.add(releaseTime);
            newTitle.setType(true);
            //title.add(true);
            this.titles.put(strings[0], newTitle);
            return true;
        }
        else{
            return false;
        }
    }

    public String getAList() {
        String textOfAnswer = new String("Your ongoings:\n");
        int i = 1;
        for (Title item:titles.values()){
            textOfAnswer += i + ") " + item.getName() + " - " + DeltaDate.get(item.getReleaseTime(), item.isType(), this.utc) + "\n";
            i++;
        }
        return textOfAnswer;
    }
    public String getATitle(String name){
        Title title = this.titles.get(name);
        String titleType;
        if (title.isType()){
            titleType = " (anime series) ";
        }
        else{
            titleType = " (anime movie) ";
        }
        return title.getName() + titleType + DeltaDate.get(title.getReleaseTime(),title.isType(),this.utc);
    }
    public InlineKeyboardMarkup getAListWithButtons(){
        InlineKeyboardMarkup inlineKeyboardMarkup = new InlineKeyboardMarkup();
        List<List<InlineKeyboardButton>> rowsInLine = new ArrayList<>();
        for (Title item:titles.values()){
            List<InlineKeyboardButton> rowInLine = new ArrayList<>();
            var titleButton = new InlineKeyboardButton();
            titleButton.setText(item.getName());
            titleButton.setCallbackData(item.getName());
            rowInLine.add(titleButton);
            rowsInLine.add(rowInLine);
        }
        inlineKeyboardMarkup.setKeyboard(rowsInLine);
        return inlineKeyboardMarkup;
    }
}

