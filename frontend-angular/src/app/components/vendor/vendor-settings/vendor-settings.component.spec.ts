import { ComponentFixture, TestBed } from '@angular/core/testing';

import { VendorSettingsComponent } from './vendor-settings.component';

describe('VendorSettingsComponent', () => {
  let component: VendorSettingsComponent;
  let fixture: ComponentFixture<VendorSettingsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [VendorSettingsComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(VendorSettingsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
