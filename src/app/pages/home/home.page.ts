// src/app/pages/home/home.page.ts
import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../services/auth.service';
import { NavController } from '@ionic/angular';
import { environment } from 'src/environments/environment';

interface MenuItem {
  title: string;
  icon: string;
  color: string;
  route: string;
  badge?: number;
}

@Component({
  selector: 'app-home',
  templateUrl: './home.page.html',
  styleUrls: ['./home.page.scss']
})
export class HomePage implements OnInit {
  user: any;
  menuItems: MenuItem[] = [
    {
      title: 'Noticias',
      icon: 'newspaper',
      color: 'primary',
      route: '/news'
    },
    {
      title: 'Eventos',
      icon: 'calendar',
      color: 'secondary',
      route: '/eventos'
    },
    {
      title: 'Videos',
      icon: 'videocam',
      color: 'tertiary',
      route: '/videos'
    },
    {
      title: 'Deudas',
      icon: 'cash',
      color: 'success',
      route: '/deudas'
    },
    {
      title: 'Horarios',
      icon: 'time',
      color: 'warning',
      route: '/horarios'
    }
  ];

  constructor(
      private authService: AuthService,
      private navCtrl: NavController,
      private repo: AuthService
  ) {}

  async ngOnInit() {
    try {
      // Get user info from your API
      const userResponse = await fetch(`${environment.apiUrl}/info_usuario`, {
        headers: {
          'Authorization': `Bearer ${this.repo.getAuthToken()}`
        }
      });
      this.user = await userResponse.json();
    } catch (error) {
      console.error('Error fetching user info:', error);
    }
  }

  navigateTo(route: string) {
    this.navCtrl.navigateForward(route);
  }

  logout() {
    this.authService.logout();
  }
}
