import { Component, Input } from '@angular/core';
import { RouterLink } from '@angular/router';
import { DashboardLatestEvaluation } from '../../core/models/evaluation.models';

@Component({
  selector: 'app-evaluation-dashboard-card',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './evaluation-dashboard-card.component.html',
  styleUrl: './evaluation-dashboard-card.component.scss',
})
export class EvaluationDashboardCardComponent {
  @Input() evaluation: DashboardLatestEvaluation | null = null;

  progressWidth(value: number | null | undefined): number {
    const percentage = Number(value ?? 0);
    return Math.min(Math.max(percentage, 0), 100);
  }
}
