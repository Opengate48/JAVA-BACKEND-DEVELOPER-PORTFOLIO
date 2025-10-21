package io.project.AnimeListSpring.service;


import java.time.*;
import java.time.temporal.Temporal;
import java.util.Calendar;

public class DeltaDate {
    public static String get(Short[] TitleReleaseTime, boolean type, Integer utc) {
        ZonedDateTime time = ZonedDateTime.now();
        String string = String.valueOf(time.getOffset());
        Integer serverUtc = Integer.parseInt(string.substring(0,3));
        int year = TitleReleaseTime[0];
        int month = TitleReleaseTime[1];
        int date = TitleReleaseTime[2];
        int hour = TitleReleaseTime[3];
        int minute = TitleReleaseTime[4];
        Calendar releaseTime = Calendar.getInstance();
        Calendar now = Calendar.getInstance();
        releaseTime.set(year, month, date, hour, minute);
        //now.add(Calendar.HOUR_OF_DAY, -(serverUtc-utc));
        if (now.before(releaseTime)) {
            Temporal releaseDate = LocalDateTime.of(year, month + 1, date, hour, minute);
            Temporal today = LocalDateTime.now();
            Duration delta = Duration.between(today, releaseDate);
            return delta.toDaysPart() + " days " + (delta.toHoursPart()+(serverUtc-utc)) + " hours " + delta.toMinutesPart() + " minutes before";
        } else {
            if (type) {
                int jump = Math.max(now.get(Calendar.DAY_OF_WEEK), releaseTime.get(Calendar.DAY_OF_WEEK)) - Math.min(now.get(Calendar.DAY_OF_WEEK), releaseTime.get(Calendar.DAY_OF_WEEK));
                now.add(Calendar.DAY_OF_WEEK, jump);
                now.set(now.get(Calendar.YEAR), now.get(Calendar.MONTH), now.get(Calendar.DATE), releaseTime.get(Calendar.HOUR_OF_DAY), releaseTime.get(Calendar.MINUTE));
                Temporal td = LocalDateTime.now();
                Temporal nw = LocalDateTime.of(now.get(Calendar.YEAR), now.get(Calendar.MONTH) + 1, now.get(Calendar.DAY_OF_MONTH), now.get(Calendar.HOUR_OF_DAY), now.get(Calendar.MINUTE));
                Duration delta = Duration.between(td, nw);
                return delta.toDaysPart() + " days " + (delta.toHoursPart()+(serverUtc-utc)) + " hours " + delta.toMinutesPart() + " minutes before";
            }
            else{
                return "the movie has already been released!";
            }
        }
    }
}
