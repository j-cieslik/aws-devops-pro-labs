#!/bin/bash
# "Bake time": serwer z nową wersją już obsługuje użytkowników, a my czekamy 2 minuty,
# żeby alarm CloudWatch zdążył zauważyć ewentualne błędy, zanim przejdziemy do kolejnego serwera.
echo "Obserwuje nowa wersje przez 120 s"
sleep 120
