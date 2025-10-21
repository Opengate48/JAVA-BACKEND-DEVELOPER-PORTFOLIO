package consumer;


import org.apache.kafka.clients.consumer.*;
import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

public class WeatherConsumer {
    private static final String TOPIC = "weather-topic";


    public static void main(String[] args) {
        Properties props = new Properties();
//        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:29092");
        //если нужно запустить отдельно jar-файл consumer при поднятых kafka и zookeeper в docker, то нужно раскомментировать
        //строку до этого комментария и закоментировать строку после этого комментария
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "weather-group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer");
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer");
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest"); //так получилось, что consumer может стартовать сильно позже producer
        //для наглядности сделал именно так, чтобы можно было увидеть, что сообщения не потерялись и дошли до consumer не смотря ни на что

        try (Consumer<String, String> consumer = new KafkaConsumer<>(props)) {
            consumer.subscribe(Collections.singletonList(TOPIC));
            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
                records.forEach(record -> {
                    System.out.printf("Получено: Город=%s, Данные=%s\n", record.key(), record.value());
                });
            }
        }
    }
}