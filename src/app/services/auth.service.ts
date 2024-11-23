import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject } from 'rxjs';
import { tap } from 'rxjs/operators';
import { environment } from '../../environments/environment';
import { Router } from '@angular/router';
import { AuthRepoService } from './auth-repo.service';
import { provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';


provideHttpClient(withInterceptorsFromDi())

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private authSubject = new BehaviorSubject<boolean>(false);
  public isAuthenticated$ = this.authSubject.asObservable();

  constructor(
    private http: HttpClient,
      private router: Router,
      private repo: AuthRepoService
  ) {
    // Check if token exists in localStorage
    const token = localStorage.getItem('auth_token');
    if (token) {
      this.authSubject.next(true);
    }
  }

  login(credentials: { username: string; password: string }): Observable<any> {
    return this.http.post(`${environment.apiUrl}/login`, credentials)
      .pipe(
        tap((response: any) => {
          if (response.authToken) {
              this.repo.setAuthToken(response.authToken);
            this.authSubject.next(true);
          }
        })
      );
  }

  requestPasswordReset(formData: { usuario: string; email: string }): Observable<any> {
    return this.http.post(`${environment.apiUrl}/reset_password`, formData);
  }

  changePassword(passwordData: {
    oldPassword: string;
    newPassword: string;
    confirmPassword: string;
  }): Observable<any> {
    return this.http.post(`${environment.apiUrl}/cambiar_password`, passwordData);
  }

  logout(): void {
      this.repo.removeAuthToken();
    this.authSubject.next(false);
    this.router.navigate(['/login']);
  }
}
