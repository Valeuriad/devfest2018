import {RouterModule} from '@angular/router';
import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { AppComponent } from './app.component';
import { MapComponent } from './components/map/map.component';
import { HttpClientModule } from '@angular/common/http';
import { SquareComponent } from './components/square/square.component';
import { WallComponent } from './components/wall/wall.component';
import { PacmanComponent } from './components/pacman/pacman.component';
import { GhostComponent } from './components/ghost/ghost.component';
import { VictoryComponent } from './components/victory/victory.component';
import { GameOverComponent } from './components/game-over/game-over.component';
import { AppRoutes } from './app.routes';

@NgModule({
  declarations: [
    AppComponent,
    MapComponent,
    SquareComponent,
    WallComponent,
    PacmanComponent,
    GhostComponent,
    VictoryComponent,
    GameOverComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    FormsModule,
    RouterModule.forRoot(AppRoutes)
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
