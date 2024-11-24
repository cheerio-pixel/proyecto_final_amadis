import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject } from 'rxjs';
import { map, tap, catchError } from 'rxjs/operators';
import { environment } from '../../environments/environment';

export interface NewsItem {
  id: number;
  title: string;
  description: string;
  imageUrl?: string;
  date: string;
  category?: string;
  url?: string;
}

@Injectable({
  providedIn: 'root'
})
export class NewsService {
  private newsSubject = new BehaviorSubject<NewsItem[]>([]);
  public news$ = this.newsSubject.asObservable();
  private lastUpdate: Date | null = null;
  private readonly REFRESH_INTERVAL = 5 * 60 * 1000; // 5 minutes

  constructor(private http: HttpClient) {}

  fetchNews(forceRefresh = false): Observable<NewsItem[]> {
    // Check if we need to refresh the data
    if (forceRefresh || !this.lastUpdate ||
        (new Date().getTime() - this.lastUpdate.getTime()) > this.REFRESH_INTERVAL) {
      return this.http.get<NewsItem[]>(`${environment.apiUrl}/noticias`).pipe(
        tap(news => {
          this.newsSubject.next(news);
          this.lastUpdate = new Date();
        }),
        catchError(error => {
          console.error('Error fetching news:', error);
          return [];
        })
      );
    }
    return this.news$;
  }

  getNewsById(id: number): Observable<NewsItem | undefined> {
    return this.news$.pipe(
      map(news => news.find(item => item.id === id))
    );
  }
}
