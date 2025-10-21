package io.project.AnimeListSpring.model;

import jakarta.persistence.*;

@Entity
public class Title {
    @Id
    @GeneratedValue
    private Long id;
    private String name;
    private String link;
    private boolean hasALink;
    private Short[] releaseTime;
    private boolean type;
    public boolean linkStatus(){
        if (hasALink){
            return true;
        }
        else{
            return false;
        }
    }

    public boolean isHasALink() {
        return hasALink;
    }

    public void setHasALink(boolean hasALink) {
        this.hasALink = hasALink;
    }

    public String getLink() {
        return link;
    }

    public void setLink(String link) {
        this.link = link;
        this.hasALink = true;
    }

    public boolean isType() {
        return type;
    }

    public void setType(boolean type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Short[] getReleaseTime() {
        return releaseTime;
    }

    public void setReleaseTime(Short[] releaseTime) {
        this.releaseTime = releaseTime;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public Title() {
    }
    public Title(Long id, String name, Short[] releaseTime, boolean type) {
        this.id = id;
        this.name = name;
        this.releaseTime = releaseTime;
        this.type = type;
    }
}
