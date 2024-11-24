// src/app/pages/login/login.page.ts
import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { LoadingController, AlertController } from '@ionic/angular';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.page.html',
  styleUrls: ['./login.page.scss']
})
export class LoginPage {
  loginForm: FormGroup;
  showPassword = false;

  constructor(
    private formBuilder: FormBuilder,
    private authService: AuthService,
    private router: Router,
    private loadingController: LoadingController,
    private alertController: AlertController
  ) {
    this.loginForm = this.formBuilder.group({
      username: ['', [Validators.required, Validators.minLength(3)]],
      password: ['', [Validators.required, Validators.minLength(6)]]
    });
  }

  async login() {
    if (this.loginForm.valid) {
      const loading = await this.loadingController.create({
        message: 'Iniciando sesión...',
        spinner: 'crescent'
      });;
      await loading.present();

      this.authService.login(this.loginForm.value).subscribe({
        next: async () => {
          await loading.dismiss();
          this.router.navigate(['/home']);
        },
        error: async (error) => {
            console.log(error);
          await loading.dismiss();
          const alert = await this.alertController.create({
            header: 'Error',
            message: 'Credenciales inválidas. Por favor, intente nuevamente.',
            buttons: ['OK']
          });
          await alert.present();
        }
      });
    } else {
      this.markFormGroupTouched(this.loginForm);
    }
  }

  async forgotPassword() {
    this.router.navigate(['/forgot-password']);
  }

  openRegistration() {
    window.open('https://uasd.edu.do/inscripcion', '_blank');
  }

  private markFormGroupTouched(formGroup: FormGroup) {
    Object.values(formGroup.controls).forEach(control => {
      control.markAsTouched();
      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      }
    });
  }

  getErrorMessage(controlName: string): string {
    const control = this.loginForm.get(controlName);
    if (control?.errors) {
      if (control.errors['required']) {
        return 'Este campo es requerido';
      }
      if (control.errors['minlength']) {
        return `Mínimo ${control.errors['minlength'].requiredLength} caracteres`;
      }
    }
    return '';
  }
}
