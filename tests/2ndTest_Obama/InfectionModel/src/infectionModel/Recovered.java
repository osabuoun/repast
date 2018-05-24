package infectionModel;

import java.util.List;






import repast.simphony.context.Context;
import repast.simphony.engine.schedule.ScheduledMethod;
import repast.simphony.engine.watcher.Watch;
import repast.simphony.engine.watcher.WatcherTriggerSchedule;
import repast.simphony.query.space.grid.GridCell;
import repast.simphony.query.space.grid.GridCellNgh;
import repast.simphony.random.RandomHelper;
import repast.simphony.space.SpatialMath;
import repast.simphony.space.continuous.ContinuousSpace;
import repast.simphony.space.continuous.NdPoint;
import repast.simphony.space.grid.Grid;
import repast.simphony.space.grid.GridPoint;
import repast.simphony.util.ContextUtils;
import repast.simphony.util.SimUtilities;

public class Recovered {
	
	private ContinuousSpace<Object> space;
	private Grid<Object> grid;
	private double immunity;

	public Recovered(ContinuousSpace<Object> space, Grid<Object> grid) {
		this.space = space;
		this.grid = grid;
		int immunity = RandomHelper.nextIntFromTo(5, 10);
		//int immunity = RandomHelper.nextIntFromTo(3, 7);
		this.immunity = immunity;
	}

	
	@ScheduledMethod(start = 1, interval = 1)
	public void step() {
		
		becomeSusceptible();
		
	}
	
	
	public void moveTowards(GridPoint pt) {
		// only move if we are not already in this grid location
		if (!pt.equals(grid.getLocation(this))) {
			NdPoint myPoint = space.getLocation(this);
			NdPoint otherPoint = new NdPoint(pt.getX(), pt.getY());
			double angle = SpatialMath.calcAngleFor2DMovement(space, myPoint, otherPoint);
			space.moveByVector(this, 2, angle, 0);
			myPoint = space.getLocation(this);
			grid.moveTo(this, (int)myPoint.getX(), (int)myPoint.getY());
		}
	}
	
	public void becomeSusceptible(){
			if (this.immunity ==0) {
				GridPoint pt = grid.getLocation(this);
				NdPoint spacePt = space.getLocation(this);
				Context<Object> context = ContextUtils.getContext(this);
				
				Susceptible susceptible = new Susceptible(space, grid);
				context.add(susceptible);
				
				space.moveTo(susceptible, spacePt.getX(), spacePt.getY());
				grid.moveTo(susceptible, pt.getX(), pt.getY());
				
				
				context.remove(this);
				
				
			}
		
	}
	
	public void decreaseImmunity(){
		if (this.immunity > 0){
			
			this.immunity = this.immunity - 0.5;
			
		}
	}
	

}
