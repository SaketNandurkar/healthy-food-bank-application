import { Component, OnInit } from '@angular/core';
import { AuthService } from './services/auth.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  title = 'Healthy Food Bank';

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    // Initialize the authentication service
    // This will restore user session if token exists in localStorage
  }
}