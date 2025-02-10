while true; do
   docker run --rm -it --rm eclipse-mosquitto mosquitto_pub -h cluster-lab5gbrawo.hamburg-main-tdg.eu.app.edge.telekom.com -p 1883 -u "gaiaxamstestuser" -P "KiG51sV2IvkANfaeZZke" -t "test_json" -m '{"key": "value", "status": "ok"}'
   sleep 5s
done
