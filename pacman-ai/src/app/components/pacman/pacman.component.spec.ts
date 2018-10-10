import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { PacmanComponent } from './pacman.component';

describe('PacmanComponent', () => {
  let component: PacmanComponent;
  let fixture: ComponentFixture<PacmanComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ PacmanComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(PacmanComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
