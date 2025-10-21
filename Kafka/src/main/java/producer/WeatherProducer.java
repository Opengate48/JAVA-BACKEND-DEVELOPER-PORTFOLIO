package producer;

import model.WeatherData;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.*;

import java.time.LocalDateTime;
import java.util.Properties;
import java.util.Random;
import java.util.concurrent.TimeUnit;

public class WeatherProducer {
    private static final String TOPIC = "weather-topic";
    private static final String[] CITIES = {"Москва", "Санкт-Петербург", "Ижевск", "Тверь", "Рязань"};
    private static final String[] CONDITIONS = {"солнечно", "облачно", "дождь"};

    public static void main(String[] args) throws InterruptedException {
        Properties props = new Properties();
//        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:29092");
        //если нужно запустить отдельно jar-файл producer при поднятых kafka и zookeeper в docker, то нужно раскомментировать
        //строку до этого комментария и закоментировать строку после этого комментария
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");

        try (Producer<String, String> producer = new KafkaProducer<>(props)) {
            while (true) {
                WeatherData weather = generateRandomWeather();
                String message = weather.toString();
                producer.send(new ProducerRecord<>(TOPIC, weather.getCity(), message), (metadata, e) -> {
                    if (e == null) {
                        System.out.printf("Отправлено: %s\n", message);
                    } else {
                        System.err.println("Ошибка отправки: " + e.getMessage());
                    }
                });
                TimeUnit.SECONDS.sleep(2);
            }
        }
    }

    private static WeatherData generateRandomWeather() {
        Random random = new Random();
        WeatherData weather = new WeatherData();
        weather.setCity(CITIES[random.nextInt(CITIES.length)]);
        weather.setTemperature(Math.round(random.nextDouble() * 35 * 10) / 10.0);
        weather.setCondition(CONDITIONS[random.nextInt(CONDITIONS.length)]);
        weather.setTimestamp(LocalDateTime.now());
        return weather;
    }
}