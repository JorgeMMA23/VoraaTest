export interface Promotion {
  id: string;
  title: string;
  description: string;
  discountPercentage: number;
  startDate: Date;
  endDate: Date;
  active: boolean;
  createdAt: Date;
}