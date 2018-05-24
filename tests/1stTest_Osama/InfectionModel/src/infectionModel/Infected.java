package infectionModel;

import java.util.ArrayList;
import java.util.List;


import repast.simphony.context.Context;
import repast.simphony.engine.schedule.ScheduledMethod;
import repast.simphony.query.space.grid.GridCell;
import repast.simphony.query.space.grid.GridCellNgh;
import repast.simphony.random.RandomHelper;
import repast.simphony.space.SpatialMath;
import repast.simphony.space.continuous.ContinuousSpace;
import repast.simphony.space.continuous.NdPoint;
import repast.simphony.space.graph.Network;
import repast.simphony.space.grid.Grid;
import repast.simphony.space.grid.GridPoint;
import repast.simphony.util.ContextUtils;
import repast.simphony.util.SimUtilities;

public class Infected {
	
	private ContinuousSpace<Object> space;
	private Grid<Object> grid;
	private boolean moved;
	private int daysInfected;

	public Infected(ContinuousSpace<Object> space, Grid<Object> grid) {
		this.space = space;
		this.grid = grid;
		this.daysInfected = 1;
	}

	@ScheduledMethod(start = 1, interval = 1)
	public void step() {
		// get the grid location of this Infected
		GridPoint pt = grid.getLocation(this);

		// use the GridCellNgh class to create GridCells for
		// the surrounding neighborhood.
		GridCellNgh<Susceptible> nghCreator = new GridCellNgh<Susceptible>(grid, pt,
				Susceptible.class, 1, 1);
		List<GridCell<Susceptible>> gridCells = nghCreator.getNeighborhood(true);
		SimUtilities.shuffle(gridCells, RandomHelper.getUniform());

		GridPoint pointWithMostSusceptible = null;
		int maxCount = -1;
		for (GridCell<Susceptible> cell : gridCells) {
			if (cell.size() > maxCount) {
				pointWithMostSusceptible = cell.getPoint();
				maxCount = cell.size();
			}
		}
		moveTowards(pointWithMostSusceptible);
		infect();
		//this.daysInfected++;
		this.daysInfected++;
		recover();
	}

	public void moveTowards(GridPoint pt) {
		// only move if we are not already in this grid location
		if (!pt.equals(grid.getLocation(this))) {
			NdPoint myPoint = space.getLocation(this);
			NdPoint otherPoint = new NdPoint(pt.getX(), pt.getY());
			double angle = SpatialMath.calcAngleFor2DMovement(space, myPoint,
					otherPoint);
			space.moveByVector(this, 1, angle, 0);
			myPoint = space.getLocation(this);
			grid.moveTo(this, (int) myPoint.getX(), (int) myPoint.getY());
			moved = true;
		}
	}

	public void infect() {
		GridPoint pt = grid.getLocation(this);
		List<Object> susceptibles = new ArrayList<Object>();
		
		for (Object obj : grid.getObjectsAt(pt.getX(), pt.getY())) {
			if (obj instanceof Susceptible) {
				susceptibles.add(obj);
			}
			if (obj instanceof Recovered) {
				((Recovered) obj).decreaseImmunity();
				
			}
			
		}
		
		if (susceptibles.size() > 0) {
			int index = RandomHelper.nextIntFromTo(0, susceptibles.size() - 1);
			Object obj = susceptibles.get(index);
			NdPoint spacePt = space.getLocation(obj);
			Context<Object> context = ContextUtils.getContext(obj);
			context.remove(obj);
			Infected infected = new Infected(space, grid);
			context.add(infected);
			space.moveTo(infected, spacePt.getX(), spacePt.getY());
			grid.moveTo(infected, pt.getX(), pt.getY());
			
			Network<Object> net = (Network<Object>)context.getProjection("infection network");
			net.addEdge(this, infected);
		}
		
	}
	
	public void recover(){
		int recoveryDays = RandomHelper.nextIntFromTo(30, 50);
		if (this.daysInfected > recoveryDays) {
			GridPoint pt = grid.getLocation(this);
			NdPoint spacePt = space.getLocation(this);
			Context<Object> context = ContextUtils.getContext(this);
			
			Recovered recovered = new Recovered(space, grid);
			context.add(recovered);
			
			space.moveTo(recovered, spacePt.getX(), spacePt.getY());
			grid.moveTo(recovered, pt.getX(), pt.getY());
			
			context.remove(this);
		}
		
	}
	

}
