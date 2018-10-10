import { WelcomeComponent } from "./welcome/welcome.component";
import { MapComponent } from "./components/map/map.component";
import { VictoryComponent } from "./victory/victory.component";
import { GameOverComponent } from "./game-over/game-over.component";


export const AppRoutes = [
    { path: '', component: WelcomeComponent },
    { path: 'play', component: MapComponent },
    { path: 'victory', component: VictoryComponent },
    { path: 'gameover', component: GameOverComponent },
];
