// src/app/pages/landing/landing.page.ts
import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-landing',
  templateUrl: './landing.page.html',
  styleUrls: ['./landing.page.scss']
})
export class LandingPage implements OnInit {
  slides = [
    {
      title: 'Bienvenidos a UASD',
      image: 'assets/images/uasd-main.jpg',
      description: 'Primera universidad del Nuevo Mundo'
    },
    {
      title: 'Nuestra Misión',
      description: 'Contribuir al desarrollo sostenible de la sociedad dominicana mediante la formación de profesionales críticos y éticos.'
    },
    {
      title: 'Nuestra Visión',
      description: 'Ser el referente de educación superior en la República Dominicana, reconocida por la calidad de su docencia.'
    },
    {
      title: 'Valores',
      description: 'Excelencia académica, ética, transparencia, compromiso social, equidad.'
    }
  ];

  constructor(private router: Router) {}

  ngOnInit() {}

  goToLogin() {
    this.router.navigate(['/login']);
  }
}
