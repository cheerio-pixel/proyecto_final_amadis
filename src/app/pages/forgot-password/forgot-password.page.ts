// src/app/pages/forgot-password/forgot-password.page.ts
import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AlertController, LoadingController, NavController } from '@ionic/angular';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-forgot-password',
  templateUrl: './forgot-password.page.html',
  styleUrls: ['./forgot-password.page.scss']
})
export class ForgotPasswordPage {
  forgotPasswordForm: FormGroup;
  isSubmitted = false;

  constructor(
    private formBuilder: FormBuilder,
    private authService: AuthService,
    private alertController: AlertController,
    private loadingController: LoadingController,
    private navCtrl: NavController
  ) {
    this.forgotPasswordForm = this.formBuilder.group({
      usuario: ['', [Validators.required, Validators.minLength(4)]],
      email: ['', [Validators.required, Validators.email]]
    });
  }

  async onSubmit() {
    this.isSubmitted = true;

    if (this.forgotPasswordForm.valid) {
      const loading = await this.loadingController.create({
        message: 'Procesando solicitud...',
        spinner: 'crescent'
      });
      
      try {
        await loading.present();
        
        // Use the async method directly
        await this.authService.requestPasswordReset(this.forgotPasswordForm.value);
        
        await loading.dismiss();
        await this.showSuccessAlert();
      } catch (error) {
        await loading.dismiss();
        await this.showErrorAlert(error);
      }
    } else {
      this.markFormGroupTouched(this.forgotPasswordForm);
    }
  }

  private async showSuccessAlert() {
    const alert = await this.alertController.create({
      header: 'Solicitud Enviada',
      message: 'Se han enviado las instrucciones de recuperación a tu correo electrónico. Por favor, revisa tu bandeja de entrada.',
      buttons: [{
        text: 'OK',
        handler: () => {
          this.navCtrl.navigateBack('/login');
        }
      }]
    });
    await alert.present();
  }

  private async showErrorAlert(error: any) {
    const alert = await this.alertController.create({
      header: 'Error',
      message: this.getErrorMessage(error),
      buttons: ['OK']
    });
    await alert.present();
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
    const control = this.forgotPasswordForm.get(controlName);
    if (control?.errors && control.touched) {
      if (control.errors['required']) {
        return 'Este campo es requerido';
      }
      if (control.errors['email']) {
        return 'Ingresa un correo electrónico válido';
      }
      if (control.errors['minlength']) {
        return `Mínimo ${control.errors['minlength'].requiredLength} caracteres`;
      }
    }
    return '';
  }

  goBack() {
    this.navCtrl.navigateBack('/login');
  }
}
