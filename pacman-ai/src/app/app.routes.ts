import { MapComponent } from "./components/map/map.component";
import { VictoryComponent } from "./components/victory/victory.component";
import { GameOverComponent } from "./components/game-over/game-over.component";


export const AppRoutes = [
    { path: '', component: MapComponent },
    { path: 'play', component: MapComponent },
    { path: 'victory', component: VictoryComponent },
    { path: 'gameover', component: GameOverComponent },
];
